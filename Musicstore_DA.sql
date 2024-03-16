-- SET 1

/*1. Who is the senior most employee based on job title?
(ordered by level)*/

select * from employee
order by levels desc
limit 1;

/*2. Which countries have the most Invoices?
USA*/

select count(*) as invoice_count, billing_country
from invoice
group by 2
order by 1 desc
limit 1;

/*3. What are top 3 values of total invoice? 
23.75, 19.8, 19.8*/

select total from invoice
order by 1 desc
limit 3;

/*4. Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals 
- Prague from Czech Republic with total of 273.24 */

select billing_city, billing_state, billing_country, sum(total) as total_money from invoice
group by 1,2,3
order by 4 desc
limit 1;

/*5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money
- cust_id: 5, Name: R Madhav, total amount: 144.54*/

select customer.customer_id, first_name, last_name, sum(invoice.total) as total_amount from customer
inner join invoice
on customer.customer_id = invoice.customer_id
group by 1,2,3
order by 4 desc
limit 1;

-- SET 2

/* 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A */

select distinct(c.email), c.first_name, c.last_name, genre.name
from customer c
join invoice on c.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by 1


/*2. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands*/

select artist.name, artist.artist_id, count(artist.artist_id) as track_count
from track
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by 2
order by 3 desc
limit 10;

/*3. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first */

select name, milliseconds from track
where milliseconds > (select avg (milliseconds) from track)
order by 2 desc;

-- SET 3

/*1. Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent*/

-- finding the sale of every artist in descinding order

with top_artist_sale as (
select artist.name, artist.artist_id, sum(invoice_line.unit_price*invoice_line.quantity) as total_sale
	from invoice_line
	join track on invoice_line.track_id = track.track_id
	join album on track.album_id = album.album_id
	join artist on album.artist_id = artist.artist_id
	group by 1,2
	order by 3 desc
)

-- if I will limit the above query by 1, we will get the top selling artist
-- in below query I have checked how much every customer has spent on each artist

select c.customer_id, c.first_name, c.last_name, tsa.name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join top_artist_sale tsa on tsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc

/*2. We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres. */

-- first group the country with no. of purchase per qty. per genre name and id
with popular_genre as (
	select count(invoice_line.quantity) as purchase, customer.country, genre.name, genre.genre_id, 
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rownum
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
--now for highest purchase per country we can select rownum=1

select * from popular_genre where rownum<=1;


/*3. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount */


with customer_per_country as (
	select customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, sum(invoice.total) as total_spent,
	row_number() over(partition by invoice.billing_country order by sum(invoice.total) desc) as rownum
	from invoice
	join customer on invoice.customer_id = customer.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)

select * from customer_per_country where rownum<=1;





























