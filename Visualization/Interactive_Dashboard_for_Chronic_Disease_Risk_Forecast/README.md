## Project Title: Interactive Dashboard for Chronic Disease Risk Forecast

### Description: 
This project introduces an interactive map developed to visualize the spread and effects of chronic diseases across the United States. Our tool highlights areas with significant disease prevalence and mortality, offering users—including public health enthusiasts, government agencies, and policymakers—the ability to explore detailed information on state-level trends, demographics, and forecasts. The project aims to support informed decision-making in healthcare resource allocation, planning, and prevention strategies.

### Installation: 
Since we used Tableau to create the interactive map as a dashboard, users are required to install Tableau Desktop or Tableau Reader.  We have not published the dashboard to Tableau Server, Tableau Public, or Tableau Cloud.  After installing Tableau Desktop/Reader, simply open the "final_dashboard.twb" Workbook and click on the Dashboard to view/use the tool.  

### Execution: 
The Dashboard depicts the United States as a heatmap. At the right hand side, there are checkboxes for "Types" (i.e. incidence, mortality, or both). Users can select either or both to view the data on the heatmap. There is also a "Topic" pane that includes the different ailments the CDC has recorded.  Users can click on one or more (or all) topics to view the heatmap change in incidence/mortality for the selected illness(es).  Below the "Topic" pane, there is a "Question" dropbox.  The CDC groups topics by questions, which users can select.  Below that is a slider for year.  Users can change the years used in the data.  At the bottom of the right hand pane is a legend for the heatmap, where darker colors reveal more prevalence in a certain state.  On the heatmap itself, hovering over a state will show a line chart corresponding to the selected illness and state, as well as display numbers for population, predicted number for next year according to they Grey model, and number of hospitals.  The next year is also predicted using Grey Prediction. To reset to view another type/topic/question, select "All" for all three before changing to the next expected view.

### Acknowledgement:
Credits to Yang Lu, Haijiao Tao, Maggie Xia, Jinglin Xu, Professor Duen Horng "Polo" Chau, and the Spring 2024 TAs for the CSE 6242 course at Georgia Institute of Technology.
