I want to create a recipe creation and management app. The app is centered around an AI recipe generation feature. The app will collect user preferences about foods (like dietary preferences, sensitivity to certain ingredients, favorite or disliked ingredients) and generate recipes using AI models. It will also let the user save and manage recipes, share them, and organize them. 

The app will contain the following features: 
- Recipe creation using AI, tailored to the user's preferences. The user will be able to add preferences like liking or disliking certain ingredients, arbitrary food preferences (like contain a lot of fiber, be voluminous and filling, not contain seed oils, be a certain texture, contain a lot of protein or carbs, be low in fats), or dietary restrictions. These preferences will be passed to the model when generating recipes. 
- Recipe generation will take into account how much time the user wants to spend making it, a limit on how many ingredients, a limit on how many cookware to use (so there doesn't have to be a lot of cleaning) and more. 
- Interactive, step-by-step "cooking" mode. The user should also be able to cook multiple recipes at once, and the app will keep the progress between the multiple recipes and let the user switch between them. 
- Recipe suggestions and ideas. For example, the user may want to eat asian food at the moment, while only having 30 minutes to cook, so suggest food ideas like easy to cook noodles, or fried rice. 
- Recipe management - rating recipes, organizing them into folders, making changes (including recipe version control, like making edits the second time the recipe is cooked and noting how it affected the recipe or changed the rating). 
- Importing recipes from recipe websites or videos (like TikTok or Instagram reels or posts). 
- Ingredient shopping lists - selecting certain recipes and getting a shopping list for ingredients that they use.
- Display macro-nutrient information for recipes.  

Use Flutter for the UI. The app will be deployed on GCP, so use their services (using the gcloud CLI) for deploying the app, AI model access, and databases (like Firebase or any other GCP database). 

Use GitHub Actions for CI/CD, and also shorebird for deployment. 

For any UI design work you do, make sure to use the impeccable skill/framework (/impeccable)
