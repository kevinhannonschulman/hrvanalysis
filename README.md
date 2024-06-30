## How Does Running Strain Affect Heart Rate Variability? ##

Running is a sport of many numbers – distances, splits, personal bests, Olympic standards and world records. However, just as important are the health metrics that can help guide a runner to become their (actual) personal best. Heart rate variability (HRV), the measure of the variation in time between heartbeats as measured in milliseconds, is one of those metrics that can be a useful indicator of stress and recovery. As a result, I was interested in exploring how four metrics of running strain (daily mileage, daily elevation gain, consecutive days and weekly mileage) affected HRV so I built data models in dbt using my own Strava and HRV data and visualized the results in Sigma to analyze the results.

### Methodology ###

I exported my Apple Health data directly from the Apple Health iPhone app and then cleaned the resulting .xml file using a Python script (based on this [template](http://www.markwk.com/data-analysis-for-apple-health.html)) to isolate the HRV data into a .csv file. Similarly, I followed this [guide](https://cj-mayes.com/2023/02/08/using-the-strava-api/) to access my Strava data using their API through the Postman app and then use a Python script to store all of my activity data in a .csv file.

I created a new project in BigQuery and dbt Cloud, loaded the .csv files into two tables in BigQuery that will serve as the sources in my dbt DAG, and initialized my dbt project.  Next, I built my data models (e.g. staging, intermediate and fact models) and .yml files in dbt Cloud to analyze the impact on HRV of each metric of running strain.

### Conclusions ###


Changes in HRV can be caused by any stressor so it’s difficult to definitively link any changes directly to these four metrics of running strain. Similarly, a single data point is not representative of potential impacts from running strain so I wanted to explore whether there were any notable trends across many data points (i.e. hundreds of runs in some categories) that could point to potential insights.

Overall, my expectation was that an increased amount of each strain metric would lead to an overall lower HRV corresponding to insufficient recovery. However, with the exception of consecutive days, this was generally not the case which was definitely surprising! While there wasn’t significant variation in the median HRV (generally 4-5 ms), the median HRV actually generally increased slightly as strain increased in daily mileage, daily elevation gain and weekly mileage with the only notable decrease found in consecutive days between three and four days.

These results might be explained by [research](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5447093/) that shows that there is a “pronounced effect of intensity on HRV… [so] any potential influence of duration is minimized.” As a result, most studies of HRV rely on intensity as measured by heart rate as found in the WHOOP Strain Score. For example, in a [study](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4786581/) of sedentary participants, an “8-week constant load aerobic training did not change vagal related HRV indices but 4-week high-intensity endurance training after 4-week constant load aerobic endurance training was sufficient enough to induce changes in nocturnal HR and HRV.” Most of these runs were at a consistent pace with an average heart rate of 161.3 bpm, which is just between my tempo (150-161 bpm) and threshold (162-174) heart rate zones, so it’s fairly expected that there wouldn’t be significant variation in HRV.

Overall, the data seems to show that these four metrics of running strain do not dramatically affect HRV. Instead, it seems to show a positive, steady response to increased strain when intensity is stable or, as stated by [Runner’s World](https://www.runnersworld.com/uk/training/a775217/live-like-an-olympian-heart-rate-variability/), “trending higher or staying stable typically means that there is a positive response to the stressors you're facing.”

There are several improvements I would make for any future HRV analysis. Specifically, more data points would definitely yield more accurate results, particularly including HRV measurements taken during sleep. In fact, [WHOOP](https://www.whoop.com/us/en/thelocker/heart-rate-variability-hrv/) calculates HRV “using a dynamic average during sleep… weighted towards your last slow wave sleep stage each night, the time when you’re in the deepest period of sleep.” Instead, my analysis uses only daytime measurements taken during days with a run (i.e. most likely my lowest HRV readings) which likely results in a baseline HRV that is significantly lower than is actually the case. Additionally, adding heart rate zone data would probably show greater variation in HRV between different running intensities due to the pronounced effect of intensity on HRV.
