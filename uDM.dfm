object DM: TDM
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object wsProtocol: TsgcWSPServer_sgc
    RPCAuthentication.Enabled = False
    OnRPC = wsProtocolRPC
    QoS.Level = qosLevel0
    QoS.Interval = 60
    QoS.Timeout = 300
    Left = 64
    Top = 24
  end
  object DriverLinkMySQL: TFDPhysMySQLDriverLink
    VendorHome = 'D:\Job\Project\Github\MyProject\ServerWebsocket\bin\'
    VendorLib = 'libmysql.dll'
    Left = 336
    Top = 144
  end
  object DBConnection: TFDConnection
    Params.Strings = (
      'Database=inv_malay'
      'Server=164.152.166.166'
      'Password=Dondon270994123!@#'
      'User_Name=dondonondonss'
      'DriverID=MySQL')
    LoginPrompt = False
    AfterConnect = DBConnectionAfterConnect
    AfterDisconnect = DBConnectionAfterDisconnect
    Left = 208
    Top = 96
  end
  object QTemp: TFDQuery
    Connection = DBConnection
    Left = 152
    Top = 200
  end
  object QPing: TFDQuery
    Connection = DBConnection
    Left = 368
    Top = 288
  end
  object tiPing: TTimer
    OnTimer = tiPingTimer
    Left = 304
    Top = 224
  end
end
