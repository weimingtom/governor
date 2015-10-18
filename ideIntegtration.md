# IDE integration #

## FlashDevelop ##

### Syntax highlighting ###

To enable Syntax highlighting in Flashdevelop we need to edit two files.

  * C:\`[APPLICATION FOLDER]`\FlashDevelop\Settings\ScintillaNET.xml
  * C:\`[APPLICATION FOLDER]`\FlashDevelop\Settings\MainMenu.xml

First download the file SYNTAX\_FLASHDEVELOP.XML from the project page and save it in the folder:

C:\Dokumente und Einstellungen\`[USER FOLDER]`\Lokale Einstellungen\Anwendungsdaten\FlashDevelop\Settings\Languages\

Now rename it to gvs.xml.


**MainMenu.xml**

To add the gsc syntax to FlashDevelop's syntax menu we have to add the line below directly under the line `<menu label="Label.Syntax" name="SyntaxMenu">` in the file MainMenu.xml.


```
<button label="&amp;gvs" click="ChangeSyntax" tag="gvs" flags="Enable:IsEditable+Check:IsEditable|IsActiveSyntax" />
```

The file should now look like this:

```
...
	<menu label="Label.Syntax" name="SyntaxMenu">
		<button label="&amp;gvs" click="ChangeSyntax" tag="gvs" flags="Enable:IsEditable+Check:IsEditable|IsActiveSyntax" />
		<button label="&amp;AS2" click="ChangeSyntax" tag="as2" flags="Enable:IsEditable+Check:IsEditable|IsActiveSyntax" />
...
```

You can now save and close the file.


**ScintillaNET.xml**

And finally we have to connect the menu entry with the syntax file we saved in step one. This happens in the file ScintillaNET.xml. Add the following line to the file directly above the `</includes>` tag.
```
    <include file="$(BaseDir)\Settings\Languages\gvs.xml" />
```

The last lines of the file should now look like this:
```
...
    <include file="$(BaseDir)\Settings\Languages\gvs.xml" />
  </includes>
</Scintilla>
```

Save the file and close it.

If FlashDevelop was open while installing the syntax, you have to restart it now.

### automatic compilation ###

FlashDevlop supports pre-Build commands. This are commands called automatically when you test/compile your project. To make the work with governor more comfortable it's possible to add the compilation of the governer script to the list of pre-Build commands. This way your scripts are always up to date when exporting or testing your project.

  1. Open the FlashDevlop project where you want to add the pre-Build command.
  1. open the project properties (Project>>Properties ...).
  1. change to the Build tab.
  1. Copy the following text in the upper text area. `$(ProjectDir)/compileGovernor.bat $(ProjectDir)\`
  1. Click OK to save the changes and close the window.

Now FlashDevelop tries to call a batch file named "compileGovernor.bat" in the projects root directory everytime you test/export your project. We have to create this file now.

  1. Create a new file in the root directory of your project and name it "compileGovernor.bat".
  1. Open this file in a text editor and copy the following content to it.
```

rem define the path to the installation folder of governorc here.
set pathGovernor=D:\programme\governorc\

rem Subfolder where your .gvs file is stored.
set pathGVS=src\gvs\

rem Name of the .gvs file.
set fileGVS=scripts.gvs

rem Name of the customToken file.
set fileCT=customToken.txt


set pathProject=%1%
%pathGovernor%governorc.exe -if %pathProject%%pathGVS%%fileGVS% -of %pathProject%%pathGVS% -ct %pathProject%%fileCT% -ns gvs -v AS3 -on Governor

```
  1. Correct paths and file names as you need them.
  1. save the file and close it.
  1. Create a new file in the project's root folder and name it "customToken.txt"

That's it.

Now your governor script get compiled automatically everytime you export your project.