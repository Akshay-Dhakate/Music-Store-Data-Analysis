create database music_store;
use music_store;

select * from album2;

# Q1: Who is the senior most employee based on job title? 

 select * from employee
 order by levels desc
 limit 1;
 
 # Q2: Which countries have the most Invoices?
 
 select count(*) as invoice_count, billing_country
 from invoice
 group by billing_country
 order by invoice_count desc;
 
 # Q3: What are top 3 values of total invoice?
 
 select total 
 from invoice
 order by total desc
 limit 3;

# Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
#Write a query that returns one city that has the highest sum of invoice totals. 
#Return both the city name & sum of all invoice totals
 
 select billing_city, SUM(total) as invoice_total
 from invoice
 group by billing_city
 order by invoice_total desc;

# Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
#Write a query that returns the person who has spent the most money.

select c.customer_id, first_name, last_name, SUM(total) as total_spending
from customer as c
join invoice as i
on c.customer_id = i.customer_id
group by c.customer_id
order by total_spending desc
limit 1;

#Q6: Write query to return the email, first name, last name, 
#& Genre of all Rock Music listeners. 
#Return your list ordered alphabetically by email starting with A.

select Distinct email, first_name, last_name
from customer 
join invoice  on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name = "Rock"
order by email;
                    
#Q7: Let's invite the artists who have written the most rock music in our dataset. 
#Write a query that returns the Artist name and total track count of the top 10 rock bands.

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from artist
join album2 on album2.artist_id = artist.artist_id
join track on track.album_id = album2.album_id
join genre on track.genre_id = genre.genre_id
where genre.name = "Rock"
group by artist.artist_id
order by number_of_songs desc
limit 10;


#Q8: Return all the track names that have a song length longer than 
#the average song length. 
#Return the Name and Milliseconds for each track. 
#Order by the song length with the longest songs listed first.

select name, milliseconds
from track 
where milliseconds > ( select avg(milliseconds) from track)
order by milliseconds desc;

##  Advance Level

# Q1: Find how much amount spent by each customer on artists? Write a query 
# to return customer name, artist name and total spent

select customer.first_name, customer.last_name, artist.name as artist_name, 
SUM(invoice_line.unit_price * invoice_line.quantity) as total_spend
from customer
join invoice  on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album2 on track.album_id = album2.album_id
join artist on album2.artist_id = artist.artist_id
group by customer.first_name, customer.last_name, artist.name
order by total_spend desc;

#Q2: We want to find out the most popular music Genre for each country. 
# We determine the most popular genre as the genre with the highest amount of purchases.
# Write a query that returns each country along with the top Genre. For countries where 
# the maximum number of purchases is shared return all Genres.

with cte as(
select COUNT(invoice_line.quantity) AS purchases, customer.country, 
genre.name as genre_name, genre.genre_id, 
row_number() over(partition by customer.country order by COUNT(invoice_line.quantity) desc) as RowNo
from invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC)
select * from cte where RowNo <=1;


#Method 2

WITH t1 AS (
	SELECT
		COUNT(i.invoice_id) purchases, c.country, g.name, g.genre_id
	FROM Invoice i
		JOIN customer c ON i.customer_id = c.customer_id
		JOIN invoice_line il ON il.Invoice_id = i.Invoice_id
		JOIN track t ON t.track_id = il.track_id
		JOIN genre g ON t.genre_id = g.genre_id
	GROUP BY c.country, g.name
	ORDER BY c.country, purchases DESC
	)

SELECT t1.*
FROM t1
JOIN (
	SELECT MAX(purchases) AS MaxPurchases, country, name, genre_id
	FROM t1
	GROUP BY Country
	)t2
ON t1.country = t2.Country
WHERE t1.purchases = t2.MaxPurchases;


# Q3: Write a query that determines the customer that has spent the most on music for each country. 
# Write a query that returns the country along with the top customer and 
# how much they spent. For countries where the top amount spent is shared, 
# provide all customers who spent this amount.

with Customter_with_country as ( 
select customer.customer_id, first_name, last_name, billing_country,
sum(total) as total_spend,
row_number() over(partition by billing_country order by sum(total) desc) as RowNo
from invoice
jOIN customer ON customer.customer_id = invoice.customer_id
group by customer.customer_id, first_name, last_name, billing_country
order by billing_country asc, total_spend desc)
SELECT * FROM Customter_with_country WHERE RowNo <= 1

