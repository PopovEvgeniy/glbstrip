unit glbstripcode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, LazFileUtils;

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
    { private declarations }
  public
    { public declarations }
  end; 

var MainWindow: TMainWindow;

implementation

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
var messages:array[0..5] of string=('Operation was successfully complete','Cant open the input file','Cant create the output file','Cant jump to the target offset','Cant allocate memory','Invalid format');
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

procedure window_setup();
begin
 Application.Title:='GLB Strip';
 MainWindow.Caption:='GLB Strip 0.4.6';
 MainWindow.BorderStyle:=bsDialog;
 MainWindow.Font.Name:=Screen.MenuFont.Name;
 MainWindow.Font.Size:=14;
end;

procedure dialog_setup();
begin
 MainWindow.OpenDialog.FileName:='*.glb';
 MainWindow.OpenDialog.DefaultExt:='*.glb';
 MainWindow.OpenDialog.Filter:='GLB pseudo-archive|*.glb';
end;

procedure interface_setup();
begin
 MainWindow.OpenButton.ShowHint:=False;
 MainWindow.SelectButton.ShowHint:=MainWindow.OpenButton.ShowHint;
 MainWindow.ExtractButton.ShowHint:=MainWindow.OpenButton.ShowHint;
 MainWindow.ExtractButton.Enabled:=False;
 MainWindow.DemonatorRadioButton.Checked:=True;
 MainWindow.FileField.Text:='';
 MainWindow.DirectoryField.Text:=MainWindow.FileField.Text;
 MainWindow.FileField.LabelPosition:=lpLeft;
 MainWindow.DirectoryField.LabelPosition:=MainWindow.FileField.LabelPosition;
 MainWindow.FileField.Enabled:=False;
 MainWindow.DirectoryField.Enabled:=MainWindow.FileField.Enabled;
end;

procedure language_setup();
begin
 MainWindow.FileField.EditLabel.Caption:='File';
 MainWindow.DirectoryField.EditLabel.Caption:='Directory';
 MainWindow.ToolPanel.Caption:='Tool';
 MainWindow.DemonatorRadioButton.Caption:='Demonator';
 MainWindow.GalactixFuseRadioButton.Caption:='Galactix fuse';
 MainWindow.OpenButton.Caption:='Open';
 MainWindow.SelectButton.Caption:='Browse';
 MainWindow.ExtractButton.Caption:='Extract';
 MainWindow.OpenDialog.Title:='Open the existing file';
 MainWindow.SelectDirectoryDialog.Title:='Select a directory';
end;

procedure setup();
begin
 window_setup();
 interface_setup();
 dialog_setup();
 language_setup();
end;

{ TMainWindow }

procedure TMainWindow.FormCreate(Sender: TObject);
begin
 setup();
end;

procedure TMainWindow.FileFieldChange(Sender: TObject);
begin
 MainWindow.ExtractButton.Enabled:=(MainWindow.FileField.Text<>'') and (MainWindow.DirectoryField.Text<>'');
end;

procedure TMainWindow.DirectoryFieldChange(Sender: TObject);
begin
 MainWindow.ExtractButton.Enabled:=(MainWindow.FileField.Text<>'') and (MainWindow.DirectoryField.Text<>'');
end;

procedure TMainWindow.OpenButtonClick(Sender: TObject);
begin
 if MainWindow.OpenDialog.Execute()=True then
 begin
  MainWindow.FileField.Text:=MainWindow.OpenDialog.FileName;
  MainWindow.DirectoryField.Text:=ExtractFilePath(MainWindow.OpenDialog.FileName);
 end;

end;

procedure TMainWindow.SelectButtonClick(Sender: TObject);
begin
 if MainWindow.SelectDirectoryDialog.Execute()=True then
 begin
  MainWindow.DirectoryField.Text:=correct_path(MainWindow.SelectDirectoryDialog.FileName);
 end;

end;

procedure TMainWindow.ExtractButtonClick(Sender: TObject);
begin
 decompile_glb(MainWindow.GalactixFuseRadioButton.Checked,MainWindow.FileField.Text,MainWindow.DirectoryField.Text);
end;

{$R *.lfm}

end.
