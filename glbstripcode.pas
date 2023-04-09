unit glbstripcode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, LazFileUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabeledEdit1Change(Sender: TObject);
    procedure LabeledEdit2Change(Sender: TObject);
    procedure OpenDialog1CanClose(Sender: TObject; var CanClose: boolean);
    procedure SelectDirectoryDialog1CanClose(Sender: TObject;
      var CanClose: boolean);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var Form1: TForm1;

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

function get_backend():string;
var backend:string;
begin
 backend:=ExtractFilePath(Application.ExeName)+'demonator';
 if Form1.RadioButton2.Checked=True then
 begin
  backend:=ExtractFilePath(Application.ExeName)+'galactixfuse';
 end;
 get_backend:=backend;
end;

procedure decompile_glb(const target:string;const directory:string);
var argument,message:string;
var messages:array[0..5] of string=('Operation successfully complete','Cant open input file','Cant create output file','Cant jump to target offset','Cant allocate memory','Invalid format');
var status:Integer;
begin
 message:='Can not execute an external program';
 argument:=convert_file_name(target)+' '+convert_file_name(directory);
 status:=execute_program(get_backend(),argument);
 if status<>-1 then
 begin
  message:=messages[status];
 end;
 ShowMessage(message);
end;

procedure window_setup();
begin
 Application.Title:='GLB Strip';
 Form1.Caption:='GLB Strip 0.3.8';
 Form1.BorderStyle:=bsDialog;
 Form1.Font.Name:=Screen.MenuFont.Name;
 Form1.Font.Size:=14;
end;

procedure dialog_setup();
begin
 Form1.OpenDialog1.FileName:='*.glb';
 Form1.OpenDialog1.DefaultExt:='*.glb';
 Form1.OpenDialog1.Filter:='GLB pseudo-archive|*.glb';
end;

procedure interface_setup();
begin
 Form1.Button1.ShowHint:=False;
 Form1.Button2.ShowHint:=Form1.Button1.ShowHint;
 Form1.Button3.ShowHint:=Form1.Button1.ShowHint;
 Form1.Button3.Enabled:=False;
 Form1.RadioButton1.Checked:=True;
 Form1.LabeledEdit1.Text:='';
 Form1.LabeledEdit2.Text:=Form1.LabeledEdit1.Text;
 Form1.LabeledEdit1.LabelPosition:=lpLeft;
 Form1.LabeledEdit2.LabelPosition:=Form1.LabeledEdit1.LabelPosition;
 Form1.LabeledEdit1.Enabled:=False;
 Form1.LabeledEdit2.Enabled:=Form1.LabeledEdit1.Enabled;
end;

procedure language_setup();
begin
 Form1.LabeledEdit1.EditLabel.Caption:='File';
 Form1.LabeledEdit2.EditLabel.Caption:='Directory';
 Form1.Label1.Caption:='Tool';
 Form1.RadioButton1.Caption:='Demonator';
 Form1.RadioButton2.Caption:='Galactix fuse';
 Form1.Button1.Caption:='Open';
 Form1.Button2.Caption:='Browse';
 Form1.Button3.Caption:='Extract';
 Form1.OpenDialog1.Title:='Open existing file';
 Form1.SelectDirectoryDialog1.Title:='Select a directory';
end;

procedure setup();
begin
 window_setup();
 interface_setup();
 dialog_setup();
 language_setup();
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
 setup();
end;

procedure TForm1.LabeledEdit1Change(Sender: TObject);
begin
 Form1.Button3.Enabled:=(Form1.LabeledEdit1.Text<>'') and (Form1.LabeledEdit2.Text<>'');
end;

procedure TForm1.LabeledEdit2Change(Sender: TObject);
begin
 Form1.Button3.Enabled:=(Form1.LabeledEdit1.Text<>'') and (Form1.LabeledEdit2.Text<>'');
end;

procedure TForm1.OpenDialog1CanClose(Sender: TObject; var CanClose: boolean);
begin
 Form1.LabeledEdit1.Text:=Form1.OpenDialog1.FileName;
 Form1.LabeledEdit2.Text:=ExtractFilePath(Form1.OpenDialog1.FileName);
end;

procedure TForm1.SelectDirectoryDialog1CanClose(Sender: TObject;
  var CanClose: boolean);
begin
 Form1.LabeledEdit2.Text:=Form1.SelectDirectoryDialog1.FileName+DirectorySeparator;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 Form1.OpenDialog1.Execute();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 Form1.SelectDirectoryDialog1.Execute();
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 decompile_glb(Form1.LabeledEdit1.Text,Form1.LabeledEdit2.Text);
end;

{$R *.lfm}

end.
