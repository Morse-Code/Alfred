## Alfred v.2 workflow: “FoldingText” workflow » Morse-Code

An Alfred workflow that compiles several useful FoldingText script extensions. Most of the individual scripts are available from the FoldingText homepage. I decided to create a streamlined workflow to house them in Alfred, which is much more user friendly than a bunch of random keyboard shortcuts.

Actions available within the workflow inlclude the following:

1. **Expand/collapse document folds to a given level.** For example, typing "ft4″ will expand all levels ≤ 4, and collapse all levels > 4. Typing "ft0″ will collapse all levels ≤ 0 (obviously this means everything).  Alternatively, the expansion level can be increased, or decreased incrementally using "+" or "-" as the keyword argument. For example, typing "ft+" into the Alfred window will increase the expansion level by 1, while "ft-" will decrease the expansion level by 1.  

2. **Export from FoldingText to OmniFocus, OmniOutliner, OmniGraffle, or OPML.** This workflow uses Robin Trew's wonderful Applescript extension to accomplish some pretty amazing stuff. I implore ÷you to read the comments in the script file for a thorough explanation of how the scrip works. The workflow is currently configured to run by using the keyword "ftomni".

3. **View current document in Marked. **This is offers a great live HTML preview of your Markdown document, and is adds the ability to easily use all of the Markdown export and formatting options available in Marked. The workflow is currently configured to run by using the keyword "ftmarked", and Marked.app must be installed to run.

4. **Create Markdown links to open Safari tab(s).** This one is all my own. The workflow action has two different behavior modes, which are both accessed using the keyword "ftlink". The default action (no modifier key) creates a Markdown link from the front most tab in Safari, and appends it as a list item to the end of the front most FoldingText document. The alternative action, which is activated depressing the command(⌘) key when selecting the action in Alfred, will create a Markdown link to each open tab in Safari and append them all to the end of the front most FoldingText document as child list items of a new parent list item. The new parent item contains the text "Links from Safari Tabs on mm/dd/yyyy", and is tagged @linklist.

Thank you to everyone who contributed to this workflow with their open source code, and please let me know if I missed anyone. A special thanks to Robin Trew for providing most of the guts for the first three workflows. The scripts used can be found on Robin's GitHub repo at [RobTrew/tree-tools][17].

   [17]: https://github.com/RobTrew/tree-tools (RobinTrew/tee-tools)

This workflow is for use with Alfred v. 2.x and will not work with earlier versions.

**Installation:**

  1. download and unpack the .zip archive: [FoldingText][18]
  2. after unpacking "FoldingText.zip", double-click “FoldingText.alfredworkflow” to install.

   [18]: http://www.morse-coder.com/wp-content/uploads/2013/01/FoldingText.zip
   