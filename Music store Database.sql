--The most senior employee
select * from employee
order by levels desc
limit 1;

-- Country with the most invoices
select billing_country, count(billing_country) as invoice_count
from invoice
group by billing_country
order by invoice_count desc
limit 1;

--Top 3 values of total invoice
select total from invoice
order by total desc
limit 3;

-- City with best customers by total sales
select billing_city, sum(total) as Total 
from invoice
group by billing_city
order by Total desc;

-- Best customer
select first_name, last_name,i.customer_id, sum(total) as invoice_total 
from invoice i
join customer c
on i.customer_id = c.customer_id
group by i.customer_id,first_name, last_name
order by invoice_total desc
limit 1;

-- List of rock genre listeners
select distinct
    c.email, c.first_name, c.last_name, g.name as genre_name
from
    customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
where 
    g.name = 'Rock'
order by 
    c.email;
	
-- Artist with most rock music

select 
    artist.artist_id, artist.name, count(track.track_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.artist_id, artist.name
order by number_of_songs desc
limit 10;

-- Tracks longer than average song lenght
select name, milliseconds from track
where milliseconds >
	(select avg(milliseconds)from track)
order by milliseconds desc;

--Amount spent by each customer on an artist.

With best_selling_artist as (
	select ar.artist_id, ar.name as artist_name, sum(il.unit_price * il.quantity) as total_sales
	from invoice_line il
	join track tr on il.track_id = tr.track_id
	join album a on tr.album_id = a.album_id
	join artist ar on a.artist_id = ar.artist_id
	group by ar.artist_id, ar.name
	order by total_sales desc
	limit 1
)
select c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity) as amount_spent
from invoice i
join customer c on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on il.track_id = t.track_id
join album a on a.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = a.artist_id
group by c.first_name, c.last_name, bsa.artist_name
order by amount_spent desc;  

-- Most popular genre with the highest amount of purchases in each country

with Rank_of_genre as (
    select c.country, g.name as Genre_name, sum(il.Quantity) as Total_Purchases,  
        ROW_NUMBER() OVER (PARTITION by c.Country ORDER by SUM(il.Quantity) DESC) AS GenreRank
    from customer c
    join Invoice i on c.Customer_id = i.Customer_id
    join Invoice_line il on i.Invoice_id = il.Invoice_id
    join Track t on il.Track_id = t.Track_id
    join Genre g on t.Genre_id = g.Genre_id
    group by 
        c.Country, g.Name
)
select Country, Genre_name
from  Rank_of_genre
where GenreRank = 1;


-- Top spending Custommer for each contry

WITH RankedSpending as (
    select 
        c.Country,
        c.First_name || ' ' || c.Last_name as CustomerName,
        sum(il.Unit_price * il.Quantity) as TotalSpent,
        row_number() over (partition by c.Country order by sum(il.unit_price * il.quantity) desc) as SpendingRank
    from 
        Customer c
        join Invoice i on c.Customer_id = i.Customer_id
        join Invoice_line il on i.Invoice_id = il.Invoice_id
    group by 
        c.Country, c.Customer_id, c.First_name, c.Last_name
)
select Country, CustomerName, TotalSpent
from RankedSpending
where SpendingRank = 1;

