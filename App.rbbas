#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  
		  'Dim th As New ThreadRunner(AddressOf DoSomething)
		  'th.Run()
		  
		  #if TEST_MODE
		    
		    Dim t As New Tests
		    t.Run()
		    
		  #else
		    
		    client = New MessagePack.RPCClient()
		    
		    client.Address = "127.0.0.1"
		    client.Port = 3002
		    client.Connect()
		    
		    client.register_service("something", new TestService)
		    
		    'Dim d As New Dictionary
		    'd.Value("name") = "TOTO"
		    
		    'client.send_request("test_svc", "test_method", 5)
		    'client.send_request("test_svc", "echo", d)
		    
		    Dim th As New ThTest(false)
		    th.Run()
		    
		  #endif
		End Sub
	#tag EndEvent


	#tag Property, Flags = &h0
		client As MessagePack.RPCClient
	#tag EndProperty


	#tag Constant, Name = TEST_MODE, Type = Boolean, Dynamic = False, Default = \"true", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
