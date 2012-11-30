#tag Class
Protected Class ThTest
Inherits MessagePack.MPThread
	#tag Event
		Sub Run()
		  
		  While true
		    
		    Try
		      App.SleepCurrentThread(200)
		      
		      If pSync Then
		        RunSync()
		      Else
		        RunAsync()
		      End
		    Catch err As MessagePack.Error
		      
		    End
		    
		  Wend
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h1000
		Sub Constructor(sync As Boolean = True)
		  // Calling the overridden superclass constructor.
		  Super.Constructor
		  
		  pSync = sync
		  pReplies = new Dictionary
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Reply(req_id As Integer, ret As Variant, error As MessagePack.Error = Nil)
		  If error <> Nil Then
		    pReplies.Value(req_id) = ret
		  Else
		    pReplies.Value(req_id) = "timeout"
		  End
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RunAsync()
		  Dim n as integer
		  Dim errors As Integer = 0
		  
		  Dim str As String
		  
		  const COUNT = 2
		  
		  For n = 1 To COUNT
		    str = "Hello " + Str(n)
		    App.client.send_request_with_callback(n, AddressOf Reply, "test_svc", "echo", str)
		  Next
		  
		  While pReplies.Count <> COUNT
		    App.SleepCurrentThread(200)
		  Wend
		  
		  For n = 1 To COUNT
		    'Check the returned value
		    If pReplies.Value(n) <> "Hello " + Str(n) Then
		      errors = errors + 1
		    End If
		  Next
		  
		  If errors <> 0 Then
		    'MsgBox( "Errors: " + Str(errors))
		    'Else
		    'Quit()
		  End IF
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RunSync()
		  Dim ret() As Variant
		  Dim n as integer
		  Dim errors As Integer = 0
		  
		  Dim str As String
		  
		  For n = 0 To 200
		    str = "Hello " + Str(n)
		    ret = App.client.blocking_request(me, "test_svc", "echo", str)
		    
		    'Check the returned value
		    If ret(0) <> str Then
		      errors = errors + 1
		    End If
		  Next
		  
		  
		  If errors <> 0 Then
		    MsgBox( "Errors: " + Str(errors))
		  Else
		    Quit()
		  End IF
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private pReplies As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pSync As Boolean
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Priority"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StackSize"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
