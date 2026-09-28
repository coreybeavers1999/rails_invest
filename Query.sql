-- Events by year by industry
select i.name, extract('YEAR' from e.created_at), count(*), sum(e.new_direction)
from stocks_industries i
    join stocks_industry_events e on i.id = e.industry_id
group by i.id, extract('YEAR' from e.created_at)
order by i.id, extract('YEAR' from e.created_at);

-- Event count and direction by industry
select i.name, count(*), sum(e.new_direction)
from stocks_industries i
         join stocks_industry_events e on i.id = e.industry_id
group by i.id
order by i.id;

select i.name, e.new_direction
from stocks_industries i
         join stocks_industry_events e on i.id = e.industry_id
order by i.id, e.id;

select * from stocks_industry_events order by id desc

select * from stocks_industries

-- 1,Technology
-- 2,Finance
-- 3,Real-estate
-- 4,Hospitality
