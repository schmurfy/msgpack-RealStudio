#tag Class
Protected Class RPCClient
Inherits TCPSocket
	#tag Event
		Sub Connected()
		  buffer = ""
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub DataAvailable()
		  buffer = buffer + ReadAll()
		  
		  ' extract every available packets
		  While process_data()
		  Wend
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function blocking_request(th as ThTest, service_name As String, method_name As String, ParamArray args As Variant) As Variant
		  Dim req_id As Integer = th.ThreadID
		  
		  _send_request(req_id, service_name, method_name, args)
		  
		  SleepingThreads.Value( req_id ) = th
		  
		  th.Suspend()
		  
		  Return th.return_values
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  // Note that this may need modifications if there are multiple constructor choices.
		  // Possible constructor calls:
		  // Constructor() -- From TCPSocket
		  // Constructor() -- From SocketCore
		  Super.Constructor
		  
		  SleepingThreads = new Dictionary
		  pCallbacks = new Dictionary
		  pServices = new Dictionary
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function process_data() As Boolean
		  Dim after As Double
		  Dim bs As New BinaryStream(buffer)
		  
		  ' first decode the header
		  Dim len As UInt32 = bs.ReadUInt32()
		  
		  ' check if we have everything
		  If bs.Length >= len + 4 Then
		    Dim data As String
		    ' Packet data
		    data = bs.Read(len)
		    
		    ' the rest
		    buffer = bs.Read(bs.Length)
		    
		    ' and process the data received
		    Dim cmd() As Variant
		    
		    cmd = MessagePack.decode(data)
		    If cmd(0) = "reply"  Then
		      Dim request_id As Integer = cmd(1)
		      If SleepingThreads.HasKey( request_id ) Then
		        Dim th As ThTest = SleepingThreads.Value(request_id)
		        th.return_values = cmd(2)
		        th.Resume
		        
		      ElseIf pCallbacks.HasKey(request_id) Then
		        Dim cb As ReplyReceived = pCallbacks.Value(request_id)
		        cb.Invoke(request_id, cmd(2))
		        
		      Else
		        RaiseEvent ReplyReceived( cmd(2) )
		      End If
		      
		      Return True
		      
		    ElseIf cmd(0) = "call" Then
		      Dim request_id As Integer = cmd(1)
		      Dim ret As Variant = run_service_method(cmd(2), cmd(3), cmd(4))
		    End If
		  End If
		  
		  Return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub register_service(module_name As String, svc As Object)
		  
		  if pServices.HasKey(module_name) Then
		    Dim err As RuntimeException
		    err.Message = "Module already defined: " + module_name
		    Raise err
		  Else
		    pServices.Value(module_name) = svc
		  End
		  
		End Sub
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Sub ReplyReceived(req_id As Integer, ret() As Variant)
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h0
		Function run_service_method(module_name As String, method_name As String, args() As Variant) As Variant
		  If pServices.HasKey(module_name) Then
		    Dim svc As Object = pServices.Value(module_name)
		    Dim type As Introspection.TypeInfo = Introspection.GetType(svc)
		    
		    ' find the method
		    Dim method As Introspection.MethodInfo = Nil
		    
		    For Each method In type.GetMethods
		      If method_name = method.Name Then
		        Exit For
		      End
		    Next
		    
		    If method.Name = method_name Then
		      Return method.Invoke(svc, args)
		      
		    Else
		      Dim err As RuntimeException
		      err.Message = "Unknown method: " + method_name
		      Raise err
		    End
		    
		  Else
		    Dim err As RuntimeException
		    err.Message = "Unknown service: " + module_name
		    Raise err
		  End
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub send_packet(cmd() As Variant)
		  
		  Dim mb As New MemoryBlock(100)
		  Dim bs As New BinaryStream(mb)
		  
		  bs.LittleEndian = False
		  mb.LittleEndian = False
		  
		  ' keep space for the header
		  bs.Position = 4
		  
		  MessagePack.encode(bs, cmd)
		  
		  Dim len As Integer = Min( bs.Position, bs.Length )
		  
		  ' now fill the header
		  mb.UInt32Value(0) = len - 4
		  
		  self.Write( mb.StringValue(0, len) )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub send_request_with_callback(req_id As Integer, cb As ReplyReceived, service_name As String, method_name As String, ParamArray args As Variant)
		  Dim cmd(4) As Variant
		  
		  cmd(0) = "call"
		  cmd(1) = req_id
		  cmd(2) = service_name
		  cmd(3) = method_name
		  cmd(4) = args
		  
		  pCallbacks.Value(req_id) = cb
		  
		  send_packet(cmd)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub _send_request(req_id As Integer, service_name As String, method_name As String, args() As Variant)
		  Dim cmd(4) As Variant
		  
		  cmd(0) = "call"
		  cmd(1) = req_id
		  cmd(2) = service_name
		  cmd(3) = method_name
		  cmd(4) = args
		  
		  send_packet(cmd)
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event ReplyReceived(values() As Variant)
	#tag EndHook


	#tag Property, Flags = &h21
		Private buffer As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pCallbacks As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pServices As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private SleepingThreads As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Address"
			Visible=true
			Group="Behavior"
			Type="String"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Port"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
