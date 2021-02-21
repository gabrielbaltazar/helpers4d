unit Helpers4D.Horse.Controller;

interface

uses
  Horse,
  System.Generics.Collections,
  System.SysUtils,
  Helpers4D.Horse;

type
  THelpers4DHorseController = class
  protected
    FRequest: THorseRequest;
    FResponse: THorseResponse;
  public
    constructor create(Req: THorseRequest; Res: THorseResponse);
  end;

  THelpers4DHorseControllerObject<T: class, constructor> = class(THelpers4DHorseController)
  protected
    FModel: T;
    FList: TObjectList<T>;

  public
    function GetBody: T; overload;
    function GetBodyList: TObjectList<T>; overload;

    function GetBody<M: class, constructor>: M; overload;
    function GetBodyList<M: class, constructor>: TObjectList<M>; overload;

    destructor Destroy; override;
  end;

implementation

{ THelpers4DHorseController }

constructor THelpers4DHorseController.create(Req: THorseRequest; Res: THorseResponse);
begin
  FRequest := Req;
  FResponse:= Res;
end;

{ THelpers4DHorseControllerObject<T> }

destructor THelpers4DHorseControllerObject<T>.Destroy;
begin
  FModel.Free;
  FList.Free;
  inherited;
end;

function THelpers4DHorseControllerObject<T>.GetBody: T;
begin
  result := FRequest.BodyAsObject<T>;
end;

function THelpers4DHorseControllerObject<T>.GetBody<M>: M;
begin
  result := FRequest.BodyAsObject<M>;
end;

function THelpers4DHorseControllerObject<T>.GetBodyList: TObjectList<T>;
begin
  result := FRequest.BodyAsObjectList<T>;
end;

function THelpers4DHorseControllerObject<T>.GetBodyList<M>: TObjectList<M>;
begin
  result := FRequest.BodyAsObjectList<M>;
end;

end.
