# RPA - Order Robot - Robocorp Certificate II

A process automation robot to complete the Robocorp course ["Certificate level II: Build a robot"](https://robocorp.com/docs/courses/build-a-robot) assignment.  
The robot automates the process of ordering several robots via the [RobotSpareBin Industries Inc. website](https://robotsparebinindustries.com/) and can be used as an assistant, which asks for the CSV file URL.

## Run the robot
As required by the course rules, the robot can be run without extra manual setup.  
This includes a vault file containing the order page URL stored in the project reposotiry.

Provided having an Robocorp account and using Robocorp Lab or [Visual Studio Code with the Robocorp extension](https://robocorp.com/docs/developer-tools/visual-studio-code/overview), there are two ways to run the robot (the tools are downloadable [here](https://robocorp.com/download)):

1. Local in Robocorp Lab or Visual Studio Code
    - Just run the robot in the IDE (no upload required)
2. As an assistant via the Robocorp Assistant App
   - [Upload the robot code to the Control Room](https://robocorp.com/docs/development-guide/control-room/configuring-robots) via the IDE
   - In the Control Room [add the robot as an assistant](https://robocorp.com/docs/control-room/operating-assistants/using-assistant-robots) 
   - [Download](https://robocorp.com/download) and install the Robocorp Assistant App
   - Run the assistant from the app (see description [here](https://robocorp.com/docs/control-room/operating-assistants/quick-guide))