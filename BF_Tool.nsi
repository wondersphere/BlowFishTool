# Version 1.0,	2022-02-17, Jefry Hamjaya
#				Initial version
#				- NSIS should be used to build an installer, but use it anyway to write a blowfish encryptor/
#				decryptor as the ConfigPC installer uses a propietary blowfish.dll NSIS plugin that seems to
#				have its own blowfish implementation (cannot be verified as the author does not provide the
#				source code) (https://nsis.sourceforge.io/Blowfish_plug-in).
#				- Use NSIS Dialog Designer (http://coolsoft.altervista.org/en/nsisdialogdesigner) to build
#				the interface (BF__GUI.nsddef & BF__GUI.nsdinc).
#				- Know issue: 
#					+ must be run on a local drive, running from network drive is not possible
#					+ text wrapping is not working

# Set the name of the installer
Outfile "BF_Tool.exe"

# Branding
Name "BlowFish Encryptor/Decryptor"
BrandingText "Nokia"

# Include the files for the GUI
!include MUI2.nsh
!include "BF__GUI.nsdinc"

# Variable Declaration
Var base64Key
Var SecretStr
Var SecretResult
Var chk_State
Var file_Result

# Call the NSIS Dialog Designer page
Page custom fnc_BF_GUI_Show

# Create a default section, at least 1 section must exist.
Section
	
SectionEnd

# Encrypt or decrypt the string
Function encrypt_decrypt
	
	# Get the strings from the GUI and save them as variables
	${NSD_GetText} $hCtl_BF_GUI_txt_Base64Key $base64Key
	${NSD_GetText} $hCtl_BF_GUI_txt_SecretStr $SecretStr
	${NSD_GetState} $hCtl_BF_GUI_chk_Decrypt $chk_State
	
	# blowfish::decrypt utilizes blowfish.dll plugin that must be copied to NSIS's plugin folder before 	compiling
	# The blowfish.dll documentation said the result should be in $8, but for some reason we need to pop the
	# values twice to get the result in $1
	${If} $chk_State != 0
		# If the operation is decrypt
		blowfish::decrypt $SecretStr "$base64Key"
		Pop $0
		Pop $1
	${Else}
		# If the operation is encrypt
		blowfish::encrypt $SecretStr $base64Key
		Pop $0
		Pop $1
	${EndIf}
	
	${NSD_SetText} $hCtl_BF_GUI_txt_SecretResult $1
	
	# Write the result to file
	FileOpen $file_Result "result.txt" w
	${If} $chk_State != 0
		# If the operation is decrypt
		FileWrite $file_Result "String:$\r$\n"
		FileWrite $file_Result "$1"
		FileWrite $file_Result "$\r$\nBlowfish:$\r$\n"
		FileWrite $file_Result "$SecretStr"
	${Else}
		# If the operation is encrypt
		FileWrite $file_Result "String:$\r$\n"
		FileWrite $file_Result "$SecretStr"
		FileWrite $file_Result "$\r$\nBlowfish:$\r$\n"
		FileWrite $file_Result "$1"
	${EndIf}
	FileClose $file_Result
	
FunctionEnd

