unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Effects, FMX.Layouts, FMX.TabControl, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FMX.Controls.Presentation,
  FMX.Edit, FireDAC.Comp.DataSet, FMX.StdCtrls, FMX.ListBox, FMX.SearchBox,
  System.Actions, FMX.ActnList;

type
  TForm1 = class(TForm)
    Rectangle1: TRectangle;
    Layout1: TLayout;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    ShadowEffect1: TShadowEffect;
    Rectangle4: TRectangle;
    ShadowEffect2: TShadowEffect;
    Rectangle5: TRectangle;
    ShadowEffect3: TShadowEffect;
    Rectangle6: TRectangle;
    Text1: TText;
    Text2: TText;
    Text3: TText;
    Text4: TText;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDQuery2: TFDQuery;
    FDQuery3: TFDQuery;
    Text5: TText;
    Edit1: TEdit;
    StyleBook1: TStyleBook;
    Rectangle7: TRectangle;
    Text6: TText;
    SpeedButton1: TSpeedButton;
    Text7: TText;
    edtCodigo: TEdit;
    Text8: TText;
    edtDescricao: TEdit;
    Text9: TText;
    edtGrupo: TEdit;
    edtPreco: TEdit;
    Text10: TText;
    Rectangle8: TRectangle;
    Text11: TText;
    SpeedButton2: TSpeedButton;
    Rectangle9: TRectangle;
    ListBox1: TListBox;
    SearchBox1: TSearchBox;
    ListBoxItem1: TListBoxItem;
    OpenDialog1: TOpenDialog;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    ChangeTabAction2: TChangeTabAction;
    ChangeTabAction3: TChangeTabAction;
    Rectangle10: TRectangle;
    Rectangle11: TRectangle;
    Rectangle12: TRectangle;
    Rectangle13: TRectangle;
    Text12: TText;
    Text13: TText;
    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FDConnection1AfterConnect(Sender: TObject);
    procedure Rectangle3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Rectangle3MouseLeave(Sender: TObject);
    procedure Rectangle4MouseLeave(Sender: TObject);
    procedure Rectangle5MouseLeave(Sender: TObject);
    procedure Rectangle2MouseLeave(Sender: TObject);
    procedure Rectangle4MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Rectangle5MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Rectangle2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Rectangle3Click(Sender: TObject);
    procedure Rectangle9Click(Sender: TObject);
    procedure edtCodigoTyping(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure ListBox1ItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure ListarProdutos;
    procedure CarregaProduto;
    procedure Rectangle4Click(Sender: TObject);
    procedure Rectangle5Click(Sender: TObject);
    procedure Text4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
   System.IOUtils, uAvisos;
{$R *.fmx}

procedure TForm1.CarregaProduto;
var Img :TStream;
begin
   FDQuery1.Open('SELECT * FROM produtos WHERE Codigo = "'+edtCodigo.Text+'"');
   edtDescricao.Text := FDQuery1.FieldByName('Descricao').AsString;
   edtGrupo.Text := FDQuery1.FieldByName('Grupo').AsString;
   edtPreco.Text := FDQuery1.FieldByName('Preco').AsString;

   Self.Fill.Bitmap.Bitmap := nil;
   FDQuery1.Open('SELECT imagem FROM imagem WHERE imagem.Codigo = "'+edtCodigo.Text+'"');
   if FDQuery1.recordcount > 0 then begin
      Img := TMemoryStream.Create;
      if not FDQuery1.Fields[0].IsNull then begin
         Img := FDQuery1.CreateBlobStream(
                FDQuery1.FieldByName('Imagem'),TBlobStreamMode.bmRead
                 );
         Rectangle9.Fill.Bitmap.Bitmap.LoadFromStream(Img);

      end else Rectangle9.Fill.Bitmap.Bitmap := nil;

   end else Rectangle9.Fill.Bitmap.Bitmap := nil;
end;

procedure TForm1.edtCodigoTyping(Sender: TObject);
begin
  CarregaProduto;
end;

procedure TForm1.FDConnection1AfterConnect(Sender: TObject);
begin
   FDConnection1.ExecSQL('CREATE TABLE IF NOT EXISTS sistema '+
                        '(Codigo INTEGER PRIMARY KEY AUTOINCREMENT,'+
                        'Projeto VARCHAR(50));'+

                        'CREATE TABLE IF NOT EXISTS imagem( '+
                        'Codigo INTEGER ,'+
                        'Imagem BLOB ); '+

                        'CREATE TABLE IF NOT EXISTS produtos '+
                        '(Codigo INTEGER PRIMARY KEY AUTOINCREMENT,'+
                        ' Descricao VARCHAR(100),'+
                        ' Grupo VARCHAR(100),'+
                        ' Preco VARCHAR(15),'+
                        ' Validade DATE );'+
                        'insert into sqlite_sequence (name)values ("produtos")');
end;

procedure TForm1.FDConnection1BeforeConnect(Sender: TObject);
begin
   FDConnection1.DriverName := 'SQLite';
   FDConnection1.Params.Values['DataBase'] := TPath.Combine(TPath.GetDocumentsPath,'Firebase.S3DB');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   FDConnection1.Connected := True;

   Edit1.Text := FDConnection1.ExecSQLScalar('SELECT Projeto FROM sistema');

   ListarProdutos;
end;

procedure TForm1.ListarProdutos;
var
   ListBoxItem1: TListBoxItem;

begin
   ListBox1.BeginUpdate;
   ListBox1.Items.Clear;
   FDQuery1.Open('SELECT * FROM produtos');
   FDQuery1.First;
   while not FDQuery1.Eof do begin
      ListBoxItem1 := TListBoxItem.Create(ListBox1);
      ListBoxItem1.Parent := ListBox1;
      ListBoxItem1.ItemData.Detail := FDQuery1.FieldByName('Grupo').AsString;
      ListBoxItem1.Size.Height := 49;
      ListBoxItem1.Size.PlatformDefault := False;
      ListBoxItem1.StyleLookup := 'listboxitembottomdetail';
      ListBoxItem1.Text := FDQuery1.FieldByName('Descricao').AsString;
      ListBoxItem1.Tag := FDQuery1.FieldByName('Codigo').AsInteger;


      ListBox1.AddObject(ListBoxItem1);
      FDQuery1.Next;
   end;


   ListBox1.EndUpdate;

end;

procedure TForm1.ListBox1ItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
   edtCodigo.Text := InttoStr(Item.Tag);
   CarregaProduto;
   ChangeTabAction3.Execute;
end;

procedure TForm1.Rectangle2MouseLeave(Sender: TObject);
begin
   TRectangle(Sender).Fill.Color :=  TAlphaColors.White;
   Text4.TextSettings.FontColor :=  Text5.TextSettings.FontColor;

end;

procedure TForm1.Rectangle2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
   TRectangle(Sender).Fill.Color := TAlphaColors.Cornflowerblue;
   Text4.TextSettings.FontColor := TAlphaColors.White;
end;

procedure TForm1.Rectangle3Click(Sender: TObject);
begin
   ChangeTabAction1.Execute;
end;

procedure TForm1.Rectangle3MouseLeave(Sender: TObject);
begin
   TRectangle(Sender).Fill.Color :=  TAlphaColors.White;
   Rectangle6.Fill.Color :=TRectangle(Sender).Fill.Color;
   Text1.TextSettings.FontColor :=  Text5.TextSettings.FontColor;
end;

procedure TForm1.Rectangle3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
   TRectangle(Sender).Fill.Color := TAlphaColors.Cornflowerblue;
   Rectangle6.Fill.Color := TRectangle(Sender).Fill.Color;
   Text1.TextSettings.FontColor := TAlphaColors.White;
end;

procedure TForm1.Rectangle4Click(Sender: TObject);
begin
   ChangeTabAction2.Execute;
end;

procedure TForm1.Rectangle4MouseLeave(Sender: TObject);
begin
   TRectangle(Sender).Fill.Color :=  TAlphaColors.White;
   Text2.TextSettings.FontColor :=  Text5.TextSettings.FontColor;
end;

procedure TForm1.Rectangle4MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
   TRectangle(Sender).Fill.Color := TAlphaColors.Cornflowerblue;
   Text2.TextSettings.FontColor := TAlphaColors.White;
end;

procedure TForm1.Rectangle5Click(Sender: TObject);
begin
   ChangeTabAction3.Execute;
end;

procedure TForm1.Rectangle5MouseLeave(Sender: TObject);
begin
   TRectangle(Sender).Fill.Color :=  TAlphaColors.White;
   Text3.TextSettings.FontColor := Text5.TextSettings.FontColor;
end;

procedure TForm1.Rectangle5MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
   TRectangle(Sender).Fill.Color := TAlphaColors.Cornflowerblue;
   Text3.TextSettings.FontColor := TAlphaColors.White;
end;

procedure TForm1.Rectangle9Click(Sender: TObject);
begin
   OpenDialog1.Execute;
   if OpenDialog1.FileName <> '' then begin
      TRectangle(Sender).Fill.Bitmap.Bitmap.LoadFromFile(OpenDialog1.FileName);
      TRectangle(Sender).Hint := OpenDialog1.FileName;
   end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
var
   ImgSalvar : TMemoryStream;
begin

   FDQuery1.Open('SELECT * FROM produtos WHERE Codigo = "'+edtCodigo.Text+'"');
   if FDQuery1.RecordCount = 0 then begin
      FDQuery1.Append;
      edtCodigo.Text := FdConnection1.ExecSQLScalar('select COALESCE(seq,0) + 1 from sqlite_sequence WHERE name = "produtos"');
      if edtCodigo.Text = ''then edtCodigo.Text := '1';
   end else
      FDQuery1.Edit;

   FDQuery1.FieldByName('Descricao').AsString := edtDescricao.Text;
   FDQuery1.FieldByName('Grupo').AsString :=  edtGrupo.Text;
   FDQuery1.FieldByName('Preco').AsString := edtPreco.Text;

   FDQuery1.Post;

   if Rectangle9.Hint <> '' then begin
      FDConnection1.ExecSQL('DELETE FROM imagem WHERE codigo =  "'+edtCodigo.Text+'"');
      FDQuery2.SQL.Clear;
      FDQuery2.SQL.Add('INSERT INTO imagem (Imagem,Codigo) values(:Imagem , :Codigo)');
      ImgSalvar := TMemoryStream.Create;
      Rectangle9.Fill.Bitmap.Bitmap.SaveToStream(ImgSalvar);
      ImgSalvar.Seek(0,0);
      FDQuery2.ParamByName('Imagem').LoadFromStream( ImgSalvar, ftBlob);
      FDQuery2.ParamByName('Codigo').AsString := edtCodigo.Text;
      FDQuery2.ExecSQL;
   end;

   AvisoPositivo('O item '+ #13 + edtDescricao.Text + #13 +' foi salvo com sucesso!');

   ListarProdutos;
   ChangeTabAction2.Execute;
end;

procedure TForm1.Text4Click(Sender: TObject);
begin
  Application.Terminate;
end;

end.
