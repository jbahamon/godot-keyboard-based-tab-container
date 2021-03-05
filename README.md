# godot-keyboard-based-tab-container
My version of Godot's Tab Container, but with keyboard functionality.

![An example from the game I'm working on.](/example.gif
"An example from the game I'm working on.")

Includes a `KeyboardBasedTabContainer` class and control scene. It's supposed
to work more or less like Godot's own TabContainer: you add each tab's content 
as a child Control node with the name you want to show up in the tab. Some styles 
are exposed as editor variables so you can style the tabs in any way you want.

In its current version, the "ui_accept" and "ui_cancel" actions are used to
enter and exit the tab's content (i.e. moving from the tabs to the content
you added and vice-versa).

In order to work properly, each child Control you add **must** implement a
`get_first_focusable_control` method which takes no parameters and returns the
control you want to be focused when you enter the tab's content. This might
become optional when Godot 3.2.4 is released.

That's it, I think! I developed this for a personal project but figured it might be
useful to others.
