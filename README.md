# AIKeyMate
AIKeyMate is an iOS keyboard extension that allows users to interact with OpenAI's GPT-based APIs directly from any app. Users can send queries to the API and receive text-based responses. The app provides a customizable list of prompts that users can select from when sending queries.

## Getting Started
To run AIKeyMate on your local machine, follow these instructions:

1. Clone the repository to your computer.
2. Open the project in Xcode.
3. Update the API key:

    Locate the line in the code where the apiKey variable is defined and replace the placeholder string with your actual OpenAI API key:
    ```swift
    apiKey = "put-your-actual-api-key"
    ```

4. Update the GPT prompts JSON file:

    AIKeyMate uses a JSON file to populate the list of prompts available for users to select. To update the list of prompts, replace the existing JSON file with your own JSON file containing the desired prompts.
    The JSON file should have the following format:

    ```json

    {
        "Prompt 1": "Description or question for Prompt 1",
        "Prompt 2": "Description or question for Prompt 2",
        ...
    }
    ```

    Update the code to use the URL of your custom JSON file by replacing the URL in the loadPromptOptions function:
    

    ```swift
    if let url = URL(string: "https://your-custom-json-file-url.com/prompts.json") {
    ```

5. Build and run the app on your desired device or simulator.

6. Add AIKeyMate as a custom keyboard on your device:

    - Go to the Settings app on your device.
    - Navigate to General > Keyboard > Keyboards.
    - Tap "Add New Keyboard..." and select AIKeyMate from the list of available keyboards.
    - Tap on AIKeyMate in the list of installed keyboards and enable "Allow Full Access".

Now you can use AIKeyMate as a keyboard extension in any app with your own API key and custom list of GPT prompts. Enjoy!
