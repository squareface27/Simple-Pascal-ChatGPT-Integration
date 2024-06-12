program main;

{$mode objfpc}{$H+}

uses
  DotEnv4Delphi,
  Classes,
  SysUtils,
  fphttpclient,
  fpjson,
  jsonparser,
  opensslsockets;

const
  API_ENDPOINT = 'https://api.openai.com/v1/chat/completions';


var
  API_KEY: String;
  Question: String;
  HttpClient: TFPHTTPClient;
  ResponseData: TStringStream;
  PostData: TStringStream;
  JsonResponse: TJSONData;
  ContentMessage: TJSONStringType;
  JsonBody: string;

begin
  API_KEY := DotEnv.Env('API_KEY');

  Write('Posez votre question : ');
  ReadLn(Question);

  JsonBody := Format(
    '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "%s"}]}',
    [Question]
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

    writeln;
    writeln(ContentMessage);
    ReadLn;
  except
    on E: Exception do
      writeln('Error: ', E.Message);
  end;

  JsonResponse.Free;
  ResponseData.Free;
  PostData.Free;
  HttpClient.Free;
end.

