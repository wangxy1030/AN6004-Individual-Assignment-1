/*
AN6004 Individual Assignment
Name: Wang Xiaoyi
Matric No.: G2403550G
*/

/*Q1*/
select *
from customertbl;
select count(distinct KFlyerID) as customer_count
from customertbl;
/*Q2*/
/* Some recorded membership type like ' SolitairePPS' contains space so that when we select distince membership time from the table, we can't fully classify the same membership type. 
   So we should firstly remove spaces from the content.*/
select distinct trim(MembershipType) as membership
from customertbl;
/*Q3*/
select trim(MembershipType) as membership, count(*) as customer_count
from customertbl
group by membership;
/*Q4*/
select *
from postalsecttbl;
select GeneralLoc, trim(MembershipType) as membership, CustGen as gender, count(*) as customer_count
from customertbl,postalsecttbl
where customertbl.PostalSect=postalsecttbl.PostalSect
group by GeneralLoc,trim(MembershipType),CustGen
order by GeneralLoc;
/*Q5*/
select GeneralLoc, trim(MembershipType) as membership, count(*) as customer_count
from customertbl,postalsecttbl
where customertbl.PostalSect=postalsecttbl.PostalSect and customertbl.MemeberSince_y>=2000
group by GeneralLoc,trim(MembershipType)
order by GeneralLoc;
/*Q6*/
select *
from tripstbl;
select *
from desttbl;
select trim(MembershipType) as membership, sum(dist) as total_distance
from customertbl, tripstbl, desttbl
where customertbl.KFlyerID=tripstbl.KFlyerID and tripstbl.RouteID=desttbl.DestID and Trip_y>=2020 and Trip_y<=2022
group by membership;
/*Q7*/
/* Some recorded aircodes contain space, which will influence the classification, 
   so we should take it into consider.*/
(select KFlyerID,AirCode,count(TripID) as TripAmt, sum(dist) as totalDistance
from tripstbl, desttbl
where tripstbl.RouteID=desttbl.DestID and AirCode not like 'NRT%' and AirCode not like 'MAN%' and AirCode not like 'LGW%' and Trip_m in (7,8,11,12) and Outbound=1
group by KFlyerID,AirCode
order by totalDistance desc
limit 2)
union
(select KFlyerID,AirCode,count(TripID) as TripAmt, sum(dist) as totalDistance
from tripstbl, desttbl
where tripstbl.RouteID=desttbl.DestID and AirCode not like 'NRT%' and AirCode not like 'MAN%' and AirCode not like 'LGW%' and Trip_m not in (7,8,11,12) and Outbound=1
group by KFlyerID,AirCode
order by totalDistance desc
limit 2);
/*Q8*/
/* Some recorded 'date_d' like '#15' and 'A8' contain other characters so that when we group by 'date_d', we can't fully classify the same date. 
   So we should firstly remove those characters from the content.*/
/* I think because a sustained conversation is defined as a conversation involves more than 1 customer-chatbot exchange in a conversation instance, 
   no matter how many exchanges it involves, it should be considered as just one sustained conversation. 
   So I use the count function to calculate the number of sustained conversations belonging to one user but not the sum function.*/
select trim(MembershipType) as membership, sum(user_chat) as use_count
from customertbl,
     (select UserID,count(*) as user_chat
	  from(
          select UserID,trim(replace(replace(Date_d, '#', ''), 'A', '')) as date_day,Date_m,Date_y,count(chatID)
          from fulllogtbl
          where ChatSource='Human'
          group by UserID,date_day,Date_m,Date_y
          having count(ChatID)>1) as A
          group by UserID) as B
where customertbl.KFlyerID=B.UserID
group by membership
order by use_count desc;
/*Q9*/
(select 'Happy Customer' as CustomerType, count(*) as CustomerCount
from(
   select KFlyerID, log(positive_emo)/log(modified_miles) as pos_emo_ratio, log(negative_emo)/log(modified_miles) as neg_emo_ratio,log(sentimentality)/log(modified_miles) as senti_ratio,log(confusion)/log(modified_miles) as confu_ratio
   from(
       select customertbl.KFlyerID, avg(Joy) as positive_emo, (avg(Anger)+avg(Fear)+avg(Sadness)+avg(Disgust))/4 as negative_emo, avg(Sentimentality) as sentimentality, avg(Confusion) as confusion,sum((dist*EliteMilesMod)) as modified_miles
       from fulllogtbl,tripstbl, desttbl,customertbl
       where tripstbl.RouteID=desttbl.DestID and fulllogtbl.UserID=customertbl.KFlyerID
       group by customertbl.KFlyerID) as T
	having pos_emo_ratio>neg_emo_ratio and pos_emo_ratio>senti_ratio and pos_emo_ratio>confu_ratio) as A1)
union
(select 'Upset Customer' as CustomerType, count(*) as CustomerCount
from(
   select KFlyerID, log(positive_emo)/log(modified_miles) as pos_emo_ratio, log(negative_emo)/log(modified_miles) as neg_emo_ratio,log(sentimentality)/log(modified_miles) as senti_ratio,log(confusion)/log(modified_miles) as confu_ratio
   from(
       select customertbl.KFlyerID, avg(Joy) as positive_emo, (avg(Anger)+avg(Fear)+avg(Sadness)+avg(Disgust))/4 as negative_emo, avg(Sentimentality) as sentimentality, avg(Confusion) as confusion,sum((dist*EliteMilesMod)) as modified_miles
       from fulllogtbl,tripstbl, desttbl,customertbl
       where tripstbl.RouteID=desttbl.DestID and fulllogtbl.UserID=customertbl.KFlyerID
       group by customertbl.KFlyerID) as T
	having neg_emo_ratio>pos_emo_ratio and neg_emo_ratio>senti_ratio and neg_emo_ratio>confu_ratio) as A2)
union
(select 'Sentimental Customer' as CustomerType, count(*) as CustomerCount
from(
   select KFlyerID, log(positive_emo)/log(modified_miles) as pos_emo_ratio, log(negative_emo)/log(modified_miles) as neg_emo_ratio,log(sentimentality)/log(modified_miles) as senti_ratio,log(confusion)/log(modified_miles) as confu_ratio
   from(
       select customertbl.KFlyerID, avg(Joy) as positive_emo, (avg(Anger)+avg(Fear)+avg(Sadness)+avg(Disgust))/4 as negative_emo, avg(Sentimentality) as sentimentality, avg(Confusion) as confusion,sum((dist*EliteMilesMod)) as modified_miles
       from fulllogtbl,tripstbl, desttbl,customertbl
       where tripstbl.RouteID=desttbl.DestID and fulllogtbl.UserID=customertbl.KFlyerID
       group by customertbl.KFlyerID) as T
	having senti_ratio>pos_emo_ratio and senti_ratio>neg_emo_ratio and senti_ratio>confu_ratio) as A3)
union
(select 'Confused Customer' as CustomerType, count(*) as CustomerCount
from(
   select KFlyerID, log(positive_emo)/log(modified_miles) as pos_emo_ratio, log(negative_emo)/log(modified_miles) as neg_emo_ratio,log(sentimentality)/log(modified_miles) as senti_ratio,log(confusion)/log(modified_miles) as confu_ratio
   from(
       select customertbl.KFlyerID, avg(Joy) as positive_emo, (avg(Anger)+avg(Fear)+avg(Sadness)+avg(Disgust))/4 as negative_emo, avg(Sentimentality) as sentimentality, avg(Confusion) as confusion,sum((dist*EliteMilesMod)) as modified_miles
       from fulllogtbl,tripstbl, desttbl,customertbl
       where tripstbl.RouteID=desttbl.DestID and fulllogtbl.UserID=customertbl.KFlyerID
       group by customertbl.KFlyerID) as T
	having confu_ratio>pos_emo_ratio and confu_ratio>neg_emo_ratio and confu_ratio>senti_ratio) as A4);



