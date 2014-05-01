functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   System
   Application
define
   Show = System.show
   Desc = td(button(text:"Show"
		    action:proc {$}
			      {Show 'Hello World'}
			   end)
	     button(text:"Close"
		    action:proc {$}
			      {Application.exit 0}
			   end))
in
   {{QTk.build Desc} show}
end