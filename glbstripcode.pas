unit glbstripcode;

{
 This software was made by Popov Evgeniy Alekseyevich.
 It is distributed under the GNU GENERAL PUBLIC LICENSE (Version 2 or higher).
}

{$mode objfpc}
{$H+}

interface

uses Classes, SysUtils, Forms, Controls, Dialogs, ExtCtrls, StdCtrls, ComCtrls;

type

  { TMainWindow }

  TMainWindow = class(TForm)
    OpenButton: TButton;
    SelectButton: TButton;
    ExtractButton: TButton;
    ToolPanel: TLabel;
    FileField: TLabeledEdit;
    DirectoryField: TLabeledEdit;
    OpenDialog: TOpenDialog;
    DemonatorRadioButton: TRadioButton;
    GalactixFuseRadioButton: TRadioButton;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    procedure OpenButtonClick(Sender: TObject);
    procedure SelectButtonClick(Sender: TObject);
    procedure ExtractButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileFieldChange(Sender: TObject);
    procedure DirectoryFieldChange(Sender: TObject);
  private
    procedure window_setup();
    procedure dialog_setup();
    procedure interface_setup();
    procedure language_setup();
    procedure setup();
  public
    { public declarations }
  end; 

var MainWindow: TMainWindow;

implementation

procedure TMainWindow.window_setup();
begin
 Application.Title:='GLB Strip';
 Self.Caption:='GLB Strip 0.5';
 Self.BorderStyle:=bsDialog;
 Self.Font.Name:=Screen.MenuFont.Name;
 Self.Font.Size:=14;
end;

procedure TMainWindow.dialog_setup();
begin
 Self.OpenDialog.FileName:='*.glb';
 Self.OpenDialog.DefaultExt:='*.glb';
 Self.OpenDialog.Filter:='GLB pseudo-archive|*.glb';
end;

procedure TMainWindow.interface_setup();
begin
 Self.OpenButton.ShowHint:=False;
 Self.SelectButton.ShowHint:=False;
 Self.ExtractButton.ShowHint:=False;
 Self.ExtractButton.Enabled:=False;
 Self.DemonatorRadioButton.Checked:=True;
 Self.FileField.Text:='';
 Self.DirectoryField.Text:='';
 Self.FileField.LabelPosition:=lpLeft;
 Self.DirectoryField.LabelPosition:=lpLeft;
 Self.FileField.Enabled:=False;
 Self.DirectoryField.Enabled:=False;
end;

procedure TMainWindow.language_setup();
begin
 Self.FileField.EditLabel.Caption:='File';
 Self.DirectoryField.EditLabel.Caption:='Directory';
 Self.ToolPanel.Caption:='Tool';
 Self.DemonatorRadioButton.Caption:='Demonator';
 Self.GalactixFuseRadioButton.Caption:='Galactix fuse';
 Self.OpenButton.Caption:='Open';
 Self.SelectButton.Caption:='Browse';
 Self.ExtractButton.Caption:='Extract';
 Self.OpenDialog.Title:='Open the existing file';
 Self.SelectDirectoryDialog.Title:='Select a directory';
end;

procedure TMainWindow.setup();
begin
 Self.window_setup();
 Self.interface_setup();
 Self.dialog_setup();
 Self.language_setup();
end;

function convert_file_name(const source:string): string;
var target:string;
begin
 target:=source;
 if Pos(' ',source)>0 then
 begin
  target:='"'+source+'"';
 end;
 convert_file_name:=target;
end;

function correct_path(const source:string ): string;
var target:string;
begin
 target:=source;
 if LastDelimiter(DirectorySeparator,source)<>Length(source) then
 begin
  target:=source+DirectorySeparator;
 end;
 correct_path:=target;
end;

function execute_program(const executable:string;const argument:string):Integer;
var code:Integer;
begin
 try
  code:=ExecuteProcess(executable,argument,[]);
 except
  code:=-1;
 end;
 execute_program:=code;
end;

function get_backend(const is_galactix:boolean):string;
var backend:string;
begin
 backend:=ExtractFilePath(Application.ExeName)+'demonator.exe';
 if is_galactix=True then
 begin
  backend:=ExtractFilePath(Application.ExeName)+'galactixfuse.exe';
 end;
 get_backend:=backend;
end;

procedure decompile_glb(const is_galactix:boolean;const target:string;const directory:string);
var argument,message:string;
var messages:array[0..7] of string=('The operation was successfully completed','Can not open the input file','Can not create the output file','Can not read data!','Can not write data!','Can not jump to the target offset','Can not allocate memory','The invalid format');
var status:Integer;
begin
 message:='Can not execute an external program';
 argument:=convert_file_name(target)+' '+convert_file_name(directory);
 status:=execute_program(get_backend(is_galactix),argument);
 if status<>-1 then
 begin
  message:=messages[status];
 end;
 ShowMessage(message);
end;

{ TMainWindow }

procedure TMainWindow.FormCreate(Sender: TObject);
begin
 Self.setup();
end;

procedure TMainWindow.FileFieldChange(Sender: TObject);
begin
 Self.ExtractButton.Enabled:=(Self.FileField.Text<>'') and (Self.DirectoryField.Text<>'');
end;

procedure TMainWindow.DirectoryFieldChange(Sender: TObject);
begin
 Self.ExtractButton.Enabled:=(Self.FileField.Text<>'') and (Self.DirectoryField.Text<>'');
end;

procedure TMainWindow.OpenButtonClick(Sender: TObject);
begin
 if Self.OpenDialog.Execute()=True then
 begin
  Self.FileField.Text:=Self.OpenDialog.FileName;
  Self.DirectoryField.Text:=ExtractFilePath(Self.OpenDialog.FileName);
 end;

end;

procedure TMainWindow.SelectButtonClick(Sender: TObject);
begin
 if Self.SelectDirectoryDialog.Execute()=True then
 begin
  Self.DirectoryField.Text:=correct_path(Self.SelectDirectoryDialog.FileName);
 end;

end;

procedure TMainWindow.ExtractButtonClick(Sender: TObject);
begin
 decompile_glb(Self.GalactixFuseRadioButton.Checked,Self.FileField.Text,Self.DirectoryField.Text);
end;

{$R *.lfm}

end.
