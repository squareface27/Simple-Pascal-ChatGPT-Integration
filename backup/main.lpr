program main;

{$mode objfpc}{$H+}

uses
  DotEnv4Delphi,
  Classes,
  SysUtils,
  fphttpclient,
  fpjson,
  jsonparser,
  opensslsockets,
  Crt;

const
  API_ENDPOINT = 'https://api.openai.com/v1/chat/completions';

var
  API_KEY: String;
  Question: String;
  Model: String;
  HttpClient: TFPHTTPClient;
  ResponseData: TStringStream;
  PostData: TStringStream;
  JsonResponse: TJSONData;
  ContentMessage: TJSONStringType;
  JsonBody: String;
  ValidChoice: Boolean;

begin
  API_KEY := DotEnv.Env('API_KEY');
  ValidChoice := False;

repeat
  WriteLn('Selection du modele : ');
  WriteLn();
  WriteLn('1 - gpt-3.5-turbo');
  WriteLn('2 - gpt-4');
  WriteLn('3 - gpt-4-turbo');
  WriteLn('4 - gpt-4o');
  WriteLn('q - Quitter');
  WriteLn();
  WriteLn();
  Write('Votre choix : ');
  ReadLn(Model);
  WriteLn();

case Model of
  '1' : begin Model := 'gpt-3.5-turbo'; ValidChoice := True; end;
  '2' : begin Model := 'gpt-4'; ValidChoice := True; end;
  '3' : begin Model := 'gpt-4-turbo'; ValidChoice := True; end;
  '4' : begin Model := 'gpt-4o'; ValidChoice := True; end;
  'q' : exit;
  else
      ClrScr();
      WriteLn('Merci d''indiquer un modele valide');
  end;
until ValidChoice;

  // Ask the user for a question
  ClrScr();
  Write(Format('(%s) Posez votre question : ', [Model]));
  ReadLn(Question);

  JsonBody := Format(
    '{"model": "%s", "messages": [{"role": "user", "content": "%s"}]}',
    [Model, Question]
  );

  HttpClient := TFPHTTPClient.Create(nil);
  ResponseData := TStringStream.Create('', TEncoding.UTF8);
  PostData := TStringStream.Create(JsonBody, TEncoding.UTF8);

  try
    HttpClient.AddHeader('Content-Type', 'application/json');
    HttpClient.AddHeader('Authorization', 'Bearer ' + API_KEY);
    HttpClient.RequestBody := PostData;
    HttpClient.Post(API_ENDPOINT, ResponseData);

    JsonResponse := GetJSON(ResponseData.DataString);

    ContentMessage := JsonResponse.FindPath('choices[0].message.content').AsString;

    WriteLn();
    WriteLn();
    WriteLn(ContentMessage);
    ReadLn;
  except
    on E: Exception do
      WriteLn('Error: ', E.Message);
  end;

  JsonResponse.Free;
  ResponseData.Free;
  PostData.Free;
  HttpClient.Free;
end.

