(

w = Window("prueba", Rect(750,500,500,500))
.front
.alwaysOnTop_(true);

~image = Image.new("/Users/dannydreamt/Documents/MSc Audio and Acoustics Engineering/2nd Semester/Computer Music - Language and System/HW 3/space.jpg");


//v = CompositeView(w, 300@300).backgroundImage_(~image);

w.view.decorator_(FlowLayout(w.bounds, 0@0, 300@50));

c = Array.fill(1, {
	arg view;
	view = CompositeView(w, 500@500)
	.backgroundImage_(~image);
//v = CompositeView(w, 70@130).backgroundImage_(~image);

	view.decorator_(FlowLayout(w.bounds, 10@10, 10@10));
});

Array.fill(1, {Slider(c[0],30@150)});

Array.fill(1, {t = StaticText(c[0],Rect(200,410,200,50))
	.font_(Font("Monaco",30))
	.background=Color.grey});//g1, Action
	t.string = "SPACE JAM";
)

w.view.decorator.reset;


