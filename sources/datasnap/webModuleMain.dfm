object WM: TWM
  OnCreate = WebModuleCreate
  Actions = <
    item
      Name = 'ReverseStringAction'
      PathInfo = '/ReverseString'
      Producer = ReverseString
    end
    item
      Name = 'ServerFunctionInvokerAction'
      PathInfo = '/ServerFunctionInvoker'
      Producer = ServerFunctionInvoker
    end
    item
      Default = True
      Name = 'DefaultAction'
      PathInfo = '/'
      OnAction = WebModuleDefaultAction
    end
    item
      Name = 'CoreRPC'
      PathInfo = '/RPC'
      OnAction = WMCoreRPCAction
    end
    item
      MethodType = mtPost
      Name = 'ClassSample'
      PathInfo = '/ClassSample/*'
      OnAction = WebModule1ClassSampleAction
    end
    item
      Name = 'ClassRadio'
      PathInfo = '/ClassRadio/*'
      OnAction = WebModule1ClassSampleAction
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  Height = 628
  Width = 814
  object DSRESTWebDispatcher1: TDSRESTWebDispatcher
    WebDispatch.PathInfo = 'datasnap*'
    Left = 96
    Top = 75
  end
  object ServerFunctionInvoker: TPageProducer
    HTMLFile = 'templates/serverfunctioninvoker.html'
    Left = 56
    Top = 184
  end
  object ReverseString: TPageProducer
    HTMLFile = 'templates/reversestring.html'
    Left = 168
    Top = 184
  end
  object WebFileDispatcher1: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/x-png'
        Extensions = 'png'
      end
      item
        MimeType = 'text/html'
        Extensions = 'htm;html'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpg;jpeg;jpe'
      end
      item
        MimeType = 'image/gif'
        Extensions = 'gif'
      end>
    BeforeDispatch = WebFileDispatcher1BeforeDispatch
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = '*'
      end
      item
        DirectoryAction = dirExclude
        DirectoryMask = '\templates\*'
      end>
    RootDirectory = '.'
    VirtualPath = '/'
    Left = 56
    Top = 136
  end
  object DSProxyGenerator1: TDSProxyGenerator
    ExcludeClasses = 'DSMetadata'
    MetaDataProvider = DSServerMetaDataProvider1
    Writer = 'Java Script REST'
    Left = 48
    Top = 248
  end
  object DSServerMetaDataProvider1: TDSServerMetaDataProvider
    Left = 208
    Top = 248
  end
  object DSProxyDispatcher1: TDSProxyDispatcher
    DSProxyGenerator = DSProxyGenerator1
    Left = 264
    Top = 128
  end
end
