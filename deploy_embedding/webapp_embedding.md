# How to embed the shiny app on website.

The following is anapproach to embed an R shiny app on your personal website


## Step 1: Clone the web shiny app from GitHub and open and run it with RStudio

After you clone the GitHub Rerpository with Rstudio. R will save the app in a folder with the name **InnoLab-Adea** and a directory you choose, you can open the web app locally. Click the "Run App" button in the server or ui file and run the app on your computer in order to be sure that there are no mistakes in the code.


## Step 2: Go to https://www.shinyapps.io/ and sign up.

Go to [The shiny website](https://www.shinyapps.io/). Enter your email address and construct a new password. This platform will enable us to deploy our R shiny app and we can access and use it online and also share it with other users. The free version allows you to deploy up to 5 applications.


## Step 3: Choose your username

Immediately after signing up, you are requested to choose your own username.


![Alt text](https://datasciencegenie.com/wp-content/uploads/2020/09/username-edited-1024x576.png)


## Step 5: Connect your RStudio to your online platform

You are now given the details to connect RStudio to your online platform. Make sure that you click the "Show secret" button and copy the two code lines (shown in the orange squares of the first screenshot) to your R console.


![Alt text1](https://datasciencegenie.com/wp-content/uploads/2020/09/rsconnect-edited-2-1024x576.png)


## Step 6: Publish your App online

Now click the blue "Publish" button (see the screenshot). Choose a name for your app and click "Publish". After that, the app has been uploaded online on shinyapp.io. You will get a URL which involves your username and the name of the app. You can copy this URL and send it to other people whom you would like to use your app. In the next step, we will use this URL to embed the app on our website.
![Alt text2](https://datasciencegenie.com/wp-content/uploads/2020/09/publish-edited-1024x576.png)

## Step 7: Embed the App on Adea's website
In order to link from Adea website to the URL of the web app , we can use the html tag `<iframe>`. In HTML the iframe tab enables us to embed an external document into our html document. Add the following html code when editing the webpage in which you want to show your app.
```
<iframe height="400" width="100%" frameborder="no" src="url_of_this app/"> </iframe>
```
Note that in "src" we provide to URL of the app. width is set to 100% in order for the app to fill the whole width of the webpage. You may have to adjust the value for "height" to find the perfect result.


## Citation
The original text of this Markdown file and images are from [citation](https://datasciencegenie.com/how-to-embed-a-shiny-app-on-website/)