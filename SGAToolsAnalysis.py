# GUI interface for analyzing YGG SGA results

#%%
# Install appropriate packages _______________________________________________
##############################################################################
import PySimpleGUI as sg
import subprocess
import sys
import os



#%%
# Design / layout of the GUI to be displayed when run ________________________
##############################################################################

# Set the theme of the GUI
sg.theme('Light Blue 2')

# The design / layout of the GUI
layout_1 = [[sg.Text('Entire file to run pre-processing:')],
            [sg.Text('File', size=(15, 1)), sg.Input(), sg.FileBrowse(key="SGAtools_file")],
            [sg.Text('Folder', size=(15, 1)), sg.Input(), sg.FolderBrowse(key="output_folder")],
            [sg.Submit(), sg.Cancel()]]

layout_2 = [[sg.Text('Select folder containing R-scripts', size=(30, 1)), sg.Input(), sg.FolderBrowse(key="Rscript_path")],
            [sg.Text('Click to process the file; outputs CSV to designated folder:')],
            [sg.Button('update_packages')],
            [sg.Button('Run Processing')],
            [sg.Text('', size=(9, 1))]]

layout_3 = [[sg.Text('Merge your SGA processed data with genetic interaction network:')],
            [sg.Text('Processed SGA data', size=(20, 1)), sg.Input(), sg.FileBrowse(key="processed_file")],
            [sg.Text('Genetic Interaction Matrix', size=(20, 1)), sg.Input(), sg.FileBrowse(key="genetic_profile_matrix")],
            [sg.Submit(), sg.Cancel()]]

layout_4 = [[sg.Text('Enter the parameters for the heatmap visualization:')],
            [sg.Text('Your query name', size=(30, 1)), sg.Input(key="query_name")],
            [sg.Text('Number of color breaks for heatmap', size=(30, 1)), sg.Input(key="col_breaks")],
            [sg.Text('Color (hex code) for negative scores', size=(30, 1)), sg.Input(key="negative_colour")],
            [sg.Text('Color (hex code) for positive scores', size=(30, 1)), sg.Input(key="positive_colour")],
            [sg.Text('Lowest bound (score value)', size=(30, 1)), sg.Input(key="lower_bound")],
            [sg.Text('Higher bound (score value)', size=(30, 1)), sg.Input(key="upper_bound")],
            [sg.Submit(), sg.Button('Run Analysis'), sg.Cancel()]]

heatmap_preview = []

bottom_text = [[sg.Text("Instructions: Click through each of the steps, completing each form in sequential order")],
               [sg.Text()],
               [sg.Text("STEP 1: Click BROWSE and select your SGA tools file, and select folder/directory where all output files will be saved. Then click SUBMIT.")],
               [sg.Text()],
               [sg.Text("STEP 2: Click RUN PROCESSING. Wait for a SGAtools_proccessed.csv file to appear in your selected folder")],
               [sg.Text()],
               [sg.Text("STEP 3: Click BROWSE and select the newly generated processed CSV file. Then select the Costanzo et al 2010 matrix. Then Click SUBMIT.")],
               [sg.Text()],
               [sg.Text("STEP 4: Enter the indicated parameters, and click GENERATE HEATMAP. You will have a saved PDF at your folder")]]

layout = [[sg.Text()],
          [sg.Column(layout_1, key='-COLStep 1-'), 
           sg.Column(layout_2, visible=False, key='-COLStep 2-'),
           sg.Column(layout_3, visible=False, key='-COLStep 3-'),
           sg.Column(layout_4, visible=False, key='-COLStep 4-'), heatmap_preview],
           [sg.Text()],
          [sg.HorizontalSeparator()],
          [sg.Text()],
          [sg.Text('Steps of the analysis - complete each step in sequential order!')],
          [sg.Text()],
          [sg.Button('Step 1'), sg.Button('Step 2'), sg.Button('Step 3'), sg.Button('Step 4'), sg.Button('Exit')],
          [sg.Text()],
          bottom_text]

# Execute the window
window = sg.Window('Yeast Genetics and Genomics 2022: SGA Analysis',
                   layout,
                   size = (1000, 600))



# Execute the GUI, and input the file from SGA Tools ________________________
##############################################################################

# While loop to maintain the persistence of the window while
# the user is interacting with the window
layout = 'Step 1'
while True:
    event, values = window.read()

    file = values['SGAtools_file'] # User provided values
    path = values['output_folder'] # User provided values
    processed_file = values["processed_file"] # User provided values
    genetic_interaction_matrix = values["genetic_profile_matrix"] # User provided values
    query_name = values['query_name']
    col_breaks = values['col_breaks']
    neg_colour = values['negative_colour']
    pos_colour = values['positive_colour']
    lower_bound = values['lower_bound']
    higher_bound = values['upper_bound']
    R_scripts_path = values['Rscript_path']

    # conditional for showing the heatmap preview
    image_file = ""
    if image_file == "":
        heatmap_preview = []
    else:
        heatmap_preview = [[sg.Image(data=image_file, key='key1', size=(5, 6))]]

    # logic to close program when user instructs to
    if event == "Cancel" or event == sg.WIN_CLOSED or event in (None, 'Exit'):
        break

    # switch to the next window in the analysis pipeline
    elif event in ['Step 1', 'Step 2', 'Step 3', 'Step 4']:
        window[f'-COL{layout}-'].update(visible=False)
        layout = event
        window[f'-COL{layout}-'].update(visible=True)

    # when button is clicked to execute the processing,
    # runs the R script, and prints the final CSV
    elif event == 'Run Processing':
        os.chdir(R_scripts_path)
        subprocess.call(
            [
                'Rscript',
                'cshl_exp7.r',
                file,
                path
            ]
        )

    # when button is clicked to update all packages,
    # runs the R script to install packages from R
    elif event == 'update_packages':
        os.chdir(R_scripts_path)
        subprocess.call(
            [
                'Rscript',
                'update_packages.r'
            ]
        )

    # when button is clicked to execute the analysis,
    # runs the R script, and print heatmap and CSV to output 
    elif event == 'Run Analysis':
        os.chdir(R_scripts_path)
        subprocess.call(
            [
                'Rscript',
                'profile_similarity_clustering.r',
                processed_file,
                genetic_interaction_matrix,
                col_breaks,
                lower_bound,
                higher_bound,
                neg_colour,
                pos_colour,
                path, # where the files will be saved
                query_name
            ]
        )

        image_file = "your_heatmap.png"


# Close the entire window once complete
window.close()



# %%