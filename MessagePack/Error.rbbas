#tag Class
Protected Class Error
Inherits RuntimeException
	#tag Method, Flags = &h1000
		Sub Constructor(msg As String)
		  me.Message = msg
		End Sub
	#tag EndMethod


End Class
#tag EndClass
