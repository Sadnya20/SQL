/*WHO IS THE SENIOR MOST EMPLOYEE ?*/
SELECT 
CONCAT(FIRST_NAM?E,LAST_NAME) AS NAME,levels, title
FROM EMPLOYEE
order by levels desc
--WHICH COUNRIES HAVE HE MOS INVOICES?
select  count (customer_id), billing_country 
from invoice
group by billing_country 
order by count(customer_id)desc
limit 10
-- WHAT ARE THE TOP 3 VALUES OF TOTAL INVOICE ?
select   total
from invoice
order by total desc
limit 3
/*WHICH CIY HAS THE BEST CUSTOMERS ? WE WOULD LIKE THROW A PROMOTTIONAL MUSIC
FESTIVAL IN THE CITY WE MADE THE MOST MONEY.WRITE A QUERY THAT RETURNS 1 CITY 
THAT HAS THE HIGHEST SUM OF INVOICE TOTALS.RETURN BOTH THE CITY NAME
AND SUM OF ALL INVOICE TOTALS*/
select sum(total)as total_invoicesum  , billing_city  as city 
from invoice 
group by billing_city 
order by sum(total) desc
limit 5
/*WHO IS THE BEST CUSTOMER ? THE CUSTOMER WHO HAS SPENT THE MOST MONEY WILL
BE DECLARED THE BEST CUSTOMER.WRITE A QUERY THAT RETURNS THE PERSON WHO HAS 
SPENT THE MOST MONEY ?*/

select  customer.customer_id ,customer.first_name,customer.last_name,sum(invoice.total)as total   
from customer
join invoice 
on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by  total desc
limit 5 
/*WRITE A QUERY TO RETURN THE EMAIL,FIRST NAME,LAST NAMEAND GENRE OF
ALL ROCK MUSIC LISTNERS.RETURN YOUR LIST ORDERED ALPHABETIC BY EMAIL STARTING
WITHA*/
select  distinct (email),first_name,last_name
from  CUSTOMER
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(select  track_id
from track 
join genre on track.genre_id=genre.genre_id
where genre.name = 'Rock'
 )
order by email 
/*LETS INVITE THE ARTISTS WHO HAVE WRITTEN THE MOST ROCK MUSIC IN OUR DATASET.
WRITE A QUERY THAT RETURNS THE ARTIST NAME AND TOTAL TRACK COUNT OF THE TOP 10 ROCK 
BANDS.*/

 select  count(artist.artist_id) as number_of_songs , (artist.name),artist.artist_id
 from track
 join album on album.album_id=track.album_id
 join artist on artist.artist_id= album.artist_id
 join genre on genre.genre_id=track.genre_id
 where genre.name like'Rock'
 order by number_of_songs
 limit 10;
 /*return all track names that have a song length  longer than  the average song
 lenght .return the name and milliseconds FOR each track .order by the song length
 with the longest songs listed first.*/

select  track.milliseconds,track.name
from track
 where milliseconds >(select avg(milliseconds)as average
from trac k)
order by milliseconds desc
/*find how much amount spent by each customer on artists?
write a query to return customer name,artist name and total
spent.*/
WITH my_cp AS (
    SELECT artist.artist_id,count(*)
           artist.name AS artist_name,
           SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id, artist.name
)
select artist_name,customer.first_name,customer.last_name,
total_sales
from my_cp
join invoice on invoice.invoice_id=my_cp.invoice_id
join customer on customer.customer_id =invoice.customer_id
group by 1 2 3 4
order by 4 desc;
/* we want to find out the most  popular music genre for each  country.
we dEtermine the most popular genre as teh genre with the  highest amount
of purchases write a query that returns each country along with the top GENRE.
FOR COUNTRIES WHERE THE MAXIMUM NUMBER OF PURCHASES IS SHRED RETURN ALL GENRES
*/
WITH POPULAR_MUSIC AS (
    SELECT
        COUNT(INVOICE_LINE.quantity) AS TOTAL_PURCHASE,
        CUSTOMER.country,
        GENRE.genre_id,
        GENRE.name,
        ROW_NUMBER() OVER (
            PARTITION BY CUSTOMER.country
            ORDER BY COUNT(INVOICE_LINE.quantity) DESC
        ) AS rownum
    FROM INVOICE
    JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
    JOIN INVOICE_LINE ON INVOICE_LINE.INVOICE_ID = INVOICE.INVOICE_ID
    JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
    JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
    GROUP BY CUSTOMER.country, GENRE.genre_id, GENRE.name
    ORDER BY CUSTOMER.country ASC, TOTAL_PURCHASE DESC
)
SELECT * FROM POPULAR_MUSIC WHERE 	rownum=1 

order by 1 desc;
/*write a query that determines the customer that has spent the
most on music  for each country.write a query that return the country 
along with the top customer and how much they spent.For countries where 
the top amount spent is shared provide all customers who spent this amount.
*/
WITH  recursive customer_country AS (
    SELECT  
        customer.customer_id,
        billing_country,
        customer.first_name,
        customer.last_name,
        SUM(invoice.total) AS total_spending
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, billing_country, customer.first_name, customer.last_name
    ORDER BY total_spending DESC
),
most_amt_spent AS (
    SELECT
        billing_country,
        MAX(total_spending) AS most_spends
    FROM customer_country
    GROUP BY billing_country
)
SELECT
    cc.first_name,
    cc.last_name,
    cc.billing_country,
    cc.total_spending,
    cc.customer_id
FROM customer_country cc
JOIN most_amt_spent mas
    ON cc.billing_country = mas.billing_country
    AND cc.total_spending = mas.most_spends
ORDER BY 3;
