unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ComCtrls, Vcl.StdCtrls, Math,
  Vcl.ExtCtrls;

type
  TDict = record
    name: string;
    count: integer;
  end;
  TForm1 = class(TForm)
    ListView1: TListView;
    OpenDialog1: TOpenDialog;
    btnOpen: TButton;
    btnReNew: TButton;
    ListView2: TListView;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel3: TPanel;
    procedure btnOpenClick(Sender: TObject);
    procedure btnReNewClick(Sender: TObject);
  private
    procedure ReNewFile;
    function OpenFile: boolean;
    procedure FillTable;
    procedure Transport;
    procedure DeleteSimilar;
    procedure DeleteWhileCycles(var j1: integer);
    procedure DeleteIfConstructions(var j1: integer);
    procedure DeleteVariables(var j1,j2: integer; checkInfo:string);
    procedure DeleteFromDictionary(var j: integer; checkInfo:string; isOperand:boolean);
    procedure DeleteModificators(checkInfo:string);
    procedure Sort;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
var CodeFile: TextFile;
    info: string;
    operands, operators: array of TDict;

{$R *.dfm}




procedure TForm1.btnOpenClick(Sender: TObject);
begin
  if OpenFile then
  begin
    btnReNew.Enabled:=true;
  end;
end;

procedure TForm1.btnReNewClick(Sender: TObject);
begin
  ReNewFile;
end;


procedure TForm1.DeleteSimilar;
var i, j: integer;
begin
  for i := 0 to High(operands)-1 do
  begin
    if operands[i].name<>'' then
    begin
      operands[i].count:=1;
      for j := i+1 to high(operands) do
      begin
        if operands[i].name=operands[j].name then
        begin
          operands[j].name:='';
          inc(operands[i].count);
        end;
      end;
    end;
  end;
  for i := 0 to High(operators)-1 do
  begin
    if operators[i].name<>'' then
    begin
      operators[i].count:=1;
      for j := i+1 to high(operators) do
      begin
        if (operators[j].name<>'') and ((operators[i].name=operators[j].name) or (operators[i].name=operators[j].name+'()')) then
        begin
          operators[j].name:='';
          inc(operators[i].count);
        end;
      end;
    end;
  end;
  for i := High(operators) downto 1 do
  begin
    if operators[i].name<>'' then
    begin
      for j := i-1 downto 0 do
      begin
        if (operators[j].name<>'') and ((operators[i].name=operators[j].name) or (operators[i].name=operators[j].name+'()')) then
        begin
          operators[j].name:='';
          inc(operators[i].count, operators[j].count);
        end;
      end;
    end;
  end;
end;



procedure TForm1.FillTable;
var i, counter, totalNum, dictCount, totalLength: Integer;
    Item: TListItem;
begin
  dictCount:=0;
  totalLength:=0;

  ListView1.Items.Clear;
  counter:=0;
  totalNum:=0;
  for i := 0 to high(operators) do
  begin
    if (operators[i].name<>'') then
    begin
      inc(counter);
      Item:=ListView1.Items.Add;
      item.Caption:=intToStr(counter);
      Item.SubItems.Add(operators[i].name);
      item.SubItems.Add(IntToStr(operators[i].count));
      totalNum:=totalNum+operators[i].count;
    end;
  end;
  Item:=ListView1.Items.Add;
  Item:=ListView1.Items.Add;
  item.Caption:='n1 = '+intToStr(counter);
  Item.SubItems.Add('');
  item.SubItems.Add('N1 = '+IntToStR(totalNum));
  totalLength:=totalLength+totalNum;
  dictCount:=dictCount+counter;

  ListView2.Items.Clear;
  counter:=0;
  totalNum:=0;
  for i := 0 to high(operands) do
  begin
    if (operands[i].name<>'') then
    begin
      inc(counter);
      Item:=ListView2.Items.Add;
      item.Caption:=intToStr(counter);
      Item.SubItems.Add(operands[i].name);
      item.SubItems.Add(IntToStr(operands[i].count));
      totalNum:=totalNum+operands[i].count;
    end;
  end;
  Item:=ListView2.Items.Add;
  Item:=ListView2.Items.Add;
  item.Caption:='n2 = '+intToStr(counter);
  Item.SubItems.Add('');
  item.SubItems.Add('N2 = '+IntToStR(totalNum));
  totalLength:=totalLength+totalNum;
  dictCount:=dictCount+counter;

  memo1.Lines.Clear;
  Memo1.Lines.Add('n = '+intToStr(dictCount));
  Memo1.Lines.Add('N = '+intToStr(totalLength));

  Memo1.Lines.Add('V = '+intToStr(Round(totalLength*Log2(dictCount))));
end;

function TForm1.OpenFile: boolean;
var buff: string;
begin
  result:=false;
  with OpenDialog1 do
  begin
    InitialDir := GetCurrentDir;
    if Execute then
    begin
      if FileExists(FileName) then
      begin
        AssignFile(CodeFile, FileName);
        Reset(CodeFile);
        info:='';
        while not EOF(CodeFile) do
        begin
          readln(CodeFile, buff);
          if (buff<>'') and ((buff[1]+buff[2]='/*')) then
          begin
            while buff[length(buff)-1]+buff[length(buff)]<>'*/' do
            begin
              readln(CodeFile, buff);
              if buff='' then
                buff:='  ';
            end;
          end;
          if Pos('//', buff)<>0 then
          begin
            //i:=Pos('//', buff);
            delete(buff, Pos('//', buff), length(buff)-Pos('//', buff)+1);
          end;
          if (buff<>'')  and (Pos('*/', buff)=0) and (Copy(buff,1,6)<>'import') and (buff[1]<>'@') and (Copy(buff,1,7)<>'package') then
          begin
            info := info + buff+' ';
          end;
        end;
        CloseFile(CodeFile);
        result:=true;
        if info<>'' then
          Transport;
      end
      else
        MessageBox(Handle, 'Error! File not exists!', 'File not exists!', MB_OK or MB_ICONERROR);
    end;
  end;
end;

procedure TForm1.ReNewFile;
var buff: string;
begin
  if FileExists(OpenDialog1.FileName) then
  begin
    AssignFile(CodeFile, OpenDialog1.FileName);
    Reset(CodeFile);
    info:='';
    while not EOF(CodeFile) do
    begin
      readln(CodeFile, buff);
      if (buff<>'') and (buff[1]+buff[2]='/*') then
        while buff[length(buff)-1]+buff[length(buff)]<>'*/' do
        begin
          readln(CodeFile, buff);
          if buff='' then
            buff:='  ';
        end;
      if Pos('//', buff)<>0 then
      begin
        //i:=Pos('//', buff);
        delete(buff, Pos('//', buff), length(buff)-Pos('//', buff)+1);
      end;
      if (buff<>'')  and (Pos('*/', buff)=0) and (Copy(buff,1,6)<>'import') and (buff[1]<>'@') and (Copy(buff,1,7)<>'package') then
      begin
        info := info + buff+' ';
      end;
    end;
    CloseFile(CodeFile);
    Transport;
  end
  else
    MessageBox(Handle, 'Error! File has been moved or deleted!', 'File not able!',
               MB_OK or MB_ICONERROR);
end;



procedure TForm1.DeleteWhileCycles(var j1: integer);
var i, k, offset, countOfDo:integer;
begin
  countOfDo:=0;
  offset:=1;
  while Pos('do', info, offset)>0 do
  begin
    if not (info[Pos('do', info, offset)+2] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) and
       not (info[Pos('do', info, offset)-1] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) then
    begin
      i:=Pos('do', info, offset);
      delete(info, i, 2);
      offset:=i-1;
      inc(countOfDo);
    end
    else
      offset:=Pos('do', info, offset)+1;
  end;
  offset:=1;
  while Pos('while', info, offset)>0 do
  begin
    if not (info[Pos('while', info, offset)+5] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) and
       not (info[Pos('while', info, offset)-1] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) then
    begin
      if countOfDo>0 then
      begin
        operators[j1].name:='do..while';
        dec(countOfDo);
      end
      else
        operators[j1].name:='while';
      inc(j1);
      i:=Pos('(', info, Pos('while', info, offset));
      delete(info, i, 1);
      k:=0;
      repeat
        if info[i]='(' then
          inc(k);
        if info[i]=')' then
          dec(k);
        inc(i);
      until (info[i]=')') and (k=0);
      info[i]:=' ';
      delete(info, Pos('while', info, offset), 5);
      offset:=i-1;
    end
    else
      offset:=Pos('while', info, offset)+1;
  end;
end;

procedure TForm1.DeleteVariables(var j1,j2: integer; checkInfo:string);
var buff: string;
    i,offset,countOfVariables: integer;
begin
  offset:=1;
  while Pos(checkInfo, info,offset)<>0 do
  begin
    countOfVariables:=1;
    i:=Pos(checkInfo, info, offset);
    if not (info[i+length(checkInfo)] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.'])
       and (not (info[i-1] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) or (i-1<1)) then
    begin
      delete(info, i, length(checkinfo));
      if (i-1>1) then
        offset:=i-1;
      while countOfVariables<>0 do
      begin
        buff:='';
        while info[i]=' ' do
          inc(i);
        while info[i] in ['a'..'z','A'..'Z', '0'..'9','_'] do
        begin
          buff:=buff+info[i];
          info[i]:=' ';
          inc(i);
        end;
        while (i<length(info)) and (info[i]=' ') do
          inc(i);
        if (info[i]='=') then
        begin
          operands[j2].name:=buff;
          inc(j2);
          buff:='';
          operators[j1].name:='=';
          inc(j1);
          delete(info,i,1);
          while info[i]=' ' do
            inc(i);
          while info[i] in ['a'..'z','A'..'Z', '0'..'9','_','.'] do
          begin
            if (info[i]='.') and (info[i+1]='.') then
            begin
              info[i]:=' ';
              info[i+1]:=' ';
              buff:=buff+'..';
              inc(i);
            end
            else
            begin
              buff:=buff+info[i];
              info[i]:=' ';
            end;
            inc(i);
          end;
          if buff<>'' then
          begin
            operands[j2].name:=buff;
            inc(j2);
          end;
        end
        else if (info[i]<>'(') then
        begin
          operands[j2].name:=buff;
          inc(j2);
        end
        else if (info[i]='(') then
        begin
          operators[j1].name:=buff+'()';
          inc(j1);
          delete(info, Pos('(',info,offset),1);
          delete(info, Pos(')',info,offset),1);
        end;
        dec(countOfVariables);
        if (info[i]=',') then
        begin
          inc(countOfVariables);
          inc(i);
        end;
      end;
    end
    else
      offset:=i+1;
  end;
end;

procedure TForm1.DeleteFromDictionary(var j: integer; checkInfo: string;isOperand: boolean);
var i,k, offset: integer;
    buff: string;
begin
  offset:=1;
  while Pos(checkInfo, info,offset)<>0 do
  begin
    i:=Pos(checkInfo, info, offset);
    if not (info[i+length(checkInfo)] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.'])
       and not (info[i-1] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) then
    begin
      delete(info, i, length(checkinfo));
      if isOperand then
        operands[j].name:=checkInfo
      else
      begin
        buff:=checkInfo;
        while info[i]=' ' do
          inc(i);
        if info[i]='(' then
        begin
          delete(info, i, 1);
          k:=0;
          repeat
            if info[i]='(' then
              inc(k);
            if info[i]=')' then
              dec(k);
            inc(i);
          until (info[i]=')') and (k=0);
          delete(info,i, 1);
          buff:=buff+'()';
        end;
        operators[j].name:=buff;
      end;
      inc(j);
      offset:=i-1;
    end
    else
      offset:=i+1;
  end;
end;

procedure TForm1.DeleteIfConstructions(var j1: integer);
var i, k, offset, countOfElse:integer;
begin
  countOfElse:=0;
  offset:=1;
  while Pos('else', info, offset)>0 do
  begin
    if not (info[Pos('else', info, offset)+4] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) and
       not (info[Pos('else', info, offset)-1] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) then
    begin
      i:=Pos('else', info, offset);
      delete(info, Pos('else', info, offset), 4);
      offset:=i-1;
      inc(countOfElse);
    end
    else
      offset:=Pos('else', info, offset)+1;
  end;
  offset:=1;
  while Pos('if', info, offset)>0 do
  begin
    if not (info[Pos('if', info, offset)+2] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) and
       not (info[Pos('if', info, offset)-1] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) then
    begin
      if countOfElse>0 then
      begin
        operators[j1].name:='if..else';
        dec(countOfElse);
      end
      else
        operators[j1].name:='if';
      inc(j1);
      i:=Pos('(', info, Pos('if', info, offset));
      delete(info, i, 1);
      k:=0;
      repeat
        if info[i]='(' then
          inc(k);
        if info[i]=')' then
          dec(k);
        inc(i);
      until (info[i]=')') and (k=0);
      info[i]:=' ';
      delete(info, Pos('if', info, offset), 2);
      offset:=i-1;
    end
    else
      offset:=Pos('if', info, offset)+1;
  end;
end;


procedure TForm1.DeleteModificators(checkInfo: string);
var i, offset: integer;
begin
  offset:=1;
  while Pos(checkInfo, info,offset)<>0 do
  begin
    i:=Pos(checkInfo, info, offset);
    if not (info[i+length(checkInfo)] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.'])
       and not (info[i-1] in ['a'..'z','A'..'Z', '0'..'9','_','''','"','.']) then
    begin
      delete(info, i, length(checkinfo));
      offset:=i-1;
    end
    else
      offset:=i+1;
  end;
end;

procedure TForm1.Transport;
var i,j,n,offset, j1,j2, k:integer;
    buff: string;
    lib:TextFile;
begin
  operands:=nil;
  operators:=nil;
  SetLength(operands, 1000);
  SetLength(operators, 1000);
  j1:=0; j2:=0; offset:=1; i:=1;
  DeleteWhileCycles(j1);
  DeleteIfConstructions(j1);
  if FileExists('lib.txt') then
  begin
    AssignFile(lib, 'lib.txt');
    Reset(lib);
    while not EOF(lib) do
    begin
      readln(lib, buff);
      DeleteVariables(j1,j2, buff);
    end;
    CloseFile(lib);
  end;
  if FileExists('lib2.txt') then
  begin
    AssignFile(lib, 'lib2.txt');
    Reset(lib);
    while not EOF(lib) do
    begin
      readln(lib, buff);
      DeleteFromDictionary(j1, buff, false);
    end;
    CloseFile(lib);
  end;
  if FileExists('lib3.txt') then
  begin
    AssignFile(lib, 'lib3.txt');
    Reset(lib);
    while not EOF(lib) do
    begin
      readln(lib, buff);
      DeleteFromDictionary(j2, buff, true);
    end;
    CloseFile(lib);
  end;
  if FileExists('lib4.txt') then
  begin
    AssignFile(lib, 'lib4.txt');
    Reset(lib);
    while not EOF(lib) do
    begin
      readln(lib, buff);
      DeleteModificators(buff);
    end;
    CloseFile(lib);
  end;
  buff:='';
  while i < length(info) do
  begin
    case info[i] of
      '[':
      begin
        info[i]:=' ';
        k:=0;
        j:=i;
        repeat
          if info[j]='[' then
            inc(k);
          if info[j]=']' then
            dec(k);
          inc(j);
        until (info[j]=']') and (k=0);
        info[j]:=' ';
        operators[j1].name:='[]';
        inc(j1);
      end;
      '(':
      begin
        buff:='';
        info[i]:=' ';
        k:=0;
        j:=i;
        repeat
          if info[j]='(' then
            inc(k);
          if info[j]=')' then
            dec(k);
          inc(j);
        until (info[j]=')') and (k=0);
        info[j]:=' ';
        while (info[i]=' ') do
          dec(i);
        if info[i] in ['a'..'z','A'..'Z', '0'..'9','_'] then
        begin
          while info[i] in ['a'..'z','A'..'Z', '0'..'9','_'] do
          begin
            buff:= info[i]+buff;
            delete(info, i, 1);
            dec(i);
          end;
          if (buff='for') then
          begin
            operators[j1].name:=buff;
            inc(j1);              
          end
          else
          begin
            operators[j1].name:=buff+'()';
            inc(j1);
          end;
        end
        else
        begin
          operators[j1].name:='()';
          inc(j1);
        end;
      end;
      ':', ';', '?':
      begin
        buff:=info[i];
        info[i]:=' ';
        if (i<length(info)) and (info[i+1] in [':','.']) then
        begin
          buff:=buff+info[i+1];
          delete(info, i+1, 1);
        end;
        operators[j1].name:=buff;
        inc(j1);
      end;
      '.':
      begin
        repeat
          buff:=info[i];
          delete(info, i, 1);
          if info[i-1]='*' then
          begin
            buff:=info[i-1]+buff;
            delete(info, i-1, 1);
            dec(i);
          end;
          operators[j1].name:=buff;
          inc(j1);
          buff:='';
          while (info[i]=' ') do
          begin
            inc(i);
          end;
          while info[i] in ['a'..'z','A'..'Z', '0'..'9'] do
          begin
            buff:=buff+ info[i];
            delete(info, i, 1);
          end;
          if info[i]='(' then
          begin
            info[i]:=' ';
            k:=0;
            j:=i;
            repeat
              if info[j]='(' then
                inc(k);
              if info[j]=')' then
                dec(k);
              inc(j);
            until (info[j]=')') and (k=0);
            delete(info,j,1);
            buff:= buff+'()';
          end;
          operators[j1].name:=buff;
          inc(j1);
        until info[i]<>'.';
        buff:='';
        dec(i);
        if info[i]=')' then
        begin
          info[i]:=' ';
          k:=0;
          j:=i;
          repeat
            if info[j]='(' then
              inc(k);
            if info[j]=')' then
              dec(k);
            dec(j);
          until ((info[j]='(') and (k=0)) or (j=0);
          info[j]:=' ';
          buff:= buff+'()';
        end;
        while info[i] = ' ' do
          dec(i);
        while (info[i] in ['a'..'z','A'..'Z', '0'..'9','_']) do
        begin
          buff:=info[i]+buff;
          delete(info, i, 1);
          dec(i);
        end;
        if Pos('()',buff)<>0 then
        begin
          operators[j1].name:=buff;
          inc(j1);
        end
        else
        begin
          operands[j2].name:=buff;
          inc(j2);
        end;
      end;
      '0'..'9':
      begin
        buff:='';
        dec(i);
        if info[i]='-' then
        begin
          buff:='-';
          info[i]:=' ';
        end;
        inc(i);
        while (i<length(info)) and (info[i]=' ') do
          inc(i);
        while info[i] in ['0'..'9']do
        begin
          buff:=buff+info[i];
          info[i]:=' ';
          inc(i);
        end;
        if (info[i]='.') then
        begin
          if (info[i+1] in ['0'..'9','.']) then
          begin
            buff:=buff+info[i];
            info[i]:=' ';
            inc(i);
            if (info[i]='.') then
            begin
              buff:=buff+info[i];
              info[i]:=' ';
              inc(i);
            end;
          end;
        end;
        while info[i] in ['0'..'9','-']do
        begin
          buff:=buff+info[i];
          info[i]:=' ';
          inc(i);
        end;
        operands[j2].name:=buff;
        inc(j2);
        dec(i);
      end;
      '"':
      begin
        buff:='"';
        delete(info,i,1);
        while info[i] <> '"' do
        begin
          buff:=buff+info[i];
          delete(info, i, 1);
        end;
        info[i]:=' ';
        operands[j2].name:=buff+'"';
        inc(j2);
      end;
      '''':
      begin
        buff:='''';
        delete(info,i,1);
        while info[i] <> '''' do
        begin
          buff:=buff+info[i];
          delete(info, i, 1);
        end;
        buff:=buff+'''';
        info[i]:=' ';
        inc(i);
        if (info[i]='.') and (i<length(info)) and (info[i+1]='.') then
        begin
          buff:=buff+info[i];
          delete(info, i, 1);
          buff:=buff+info[i];
          delete(info, i, 1);
          buff:=buff+info[i];
          delete(info, i, 1);
          while info[i] <> '''' do
          begin
            buff:=buff+info[i];
            delete(info, i, 1);
          end;
          buff:=buff+info[i];
          delete(info, i, 1);
        end;
        operands[j2].name:=buff;
        inc(j2);
        dec(i);
      end;
    end;
    inc(i);
  end;
  i:=0;
  while i<length(info) do
  begin
    case info[i] of
      '+', '-', '*', '/','%', '<','>', '!', '|','^','&','~':
      begin
        buff:=info[i];
        info[i]:=' ';
        if info[i+1] in ['<','>'] then
        begin
          buff:=buff+info[i+1];
          delete(info, i+1, 1);
        end;
        if info[i+1] = '=' then
        begin
          buff:= buff+'=';
          info[i+1]:=' ';
          if info[i+2]='>' then
          begin
            buff:=buff+'>';
            info[i+2]:=' ';
          end;
        end
        else if (info[i+1] in ['+','-','>','<','|','&']) then
        begin
          buff:=buff+info[i+1];
          delete(info, i+1, 1);
          dec(i);
        end;
        operators[j1].name:=buff;
        inc(j1);
        if buff='->' then
        begin
          buff:='';
          dec(i);
          while info[i]=' ' do
            dec(i);
          while info[i] in ['a'..'z','A'..'Z', '0'..'9','_',',',' '] do
          begin
            if not (info[i] in [',',' ']) then
            begin
              buff:=info[i]+buff;
              info[i]:=' ';
            end
            else
            begin
              if info[i]=',' then
              begin
                operators[j1].name:=',';
                inc(j1);
                info[i]:=' ';
                while info[i] = ' ' do
                  dec(i);
                operands[j2].name:=buff;
                inc(j2);
                buff:='';
              end;
            end;
            dec(i);
          end;
          if buff<>'' then
          begin
            operands[j2].name:=buff;
            inc(j2);
            buff:='';
          end;
        end;
      end;
      '=':
      begin
        buff:=info[i];
        info[i]:=' ';
        if (i<length(info)) and (info[i+1]='=') then
        begin
          buff:=buff+'=';
          info[i+1]:=' ';
        end;
        if (i<length(info)) and (info[i+1]='~') then
        begin
          buff:=buff+'~';
          info[i+1]:=' ';
        end;
        operators[j1].name:=buff;
        inc(j1);
        info[i]:=' ';
        dec(i);
        buff:='';
        while (i>0) and (info[i]=' ') do
          dec(i);
        while (i>0) and (info[i] in ['a'..'z','A'..'Z','0'..'9','_']) do
        begin
          buff:=info[i]+buff;
          delete(info, i, 1);
          dec(i);
        end;
        if buff<>'' then
        begin
          operands[j2].name:=buff;
          inc(j2);
        end;
        inc(i);
        buff:='';
        while (info[i]=' ') do
          inc(i);
        if info[i]='/' then
        begin
          buff:='/';
          delete(info,i,1);
          while info[i] <> '/' do
          begin
            buff:=buff+info[i];
            info[i]:=' ';
            inc(i);
          end;
          info[i]:=' ';
          buff:=buff+'/';
          operands[j2].name:=buff;
          inc(j2);
        end;
      end;
    end;
    inc(i);
  end;
  i:=1;
  while i<=length(info) do
  begin
    case info[i] of
      '{':
      begin
        info[i]:=' ';
        k:=0;
        j:=i;
        repeat
          if info[j]='{' then
            inc(k);
          if info[j]='}' then
            dec(k);
          inc(j);
        until (info[j]='}') and (k=0);
        info[j]:=' ';
        operators[j1].name:='{}';
        inc(j1);
      end;
      ',':
      begin
        info[i]:=' ';
        operators[j1].name:=',';
        inc(j1);
      end;
    end;
    inc(i);
  end;
  i:=0;
  while i <= high(operands) do
  begin
    buff:=operands[i].name;
    if buff<>'' then
    begin
      offset:=1; j:=1;
      if buff[length(buff)]=')' then
        delete(buff, length(buff)-1, 2);
      while (j<>0) do
      begin
        j:=Pos(buff, info, offset);
        if (j<>0) and
              not (info[j+length(buff)] in ['a'..'z','A'..'Z', '0'..'9','_']) and
              not (info[j-1] in ['a'..'z','A'..'Z', '0'..'9','_']) then
        begin
          operands[j2].name:=operands[i].name;
          inc(j2);
          k:=j;
          for n := 1 to length(buff) do
          begin
            delete(info, k,1);
          end;
        end
        else
          offset:=j+1;
      end;
    end;
    inc(i);
  end;
  i:=0;
  while i <= high(operands) do
  begin
    buff:=operands[i].name;
    if buff<>'' then
    begin
      j:=0;
      while j<=high(operators) do
      begin
        if (operators[j].name=buff) then
        begin
          operators[j].name:='';
          operands[j2].name:=buff;
          inc(j2);
        end;
        inc(j);
      end;
    end;
    inc(i);
  end;
  DeleteSimilar;
  Sort;
  FillTable;
end;

procedure TForm1.Sort;
var i, j:integer;
    temp: TDict;
begin
  for i:=0 to High(operands)-1 do
  begin
    for j := i+1 to High(operands) do
    begin
      if operands[i].count<operands[j].count then
      begin
        temp:=operands[i];
        operands[i]:=operands[j];
        operands[j]:=temp;
      end;
    end;
  end;
  for i:=0 to High(operators)-1 do
  begin
    for j := i+1 to High(operators) do
    begin
      if operators[i].count<operators[j].count then
      begin
        temp:=operators[i];
        operators[i]:=operators[j];
        operators[j]:=temp;
      end;
    end;
  end;
end;

end.
