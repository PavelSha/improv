package 
{	
	/**
     *
     * Sample: Basic Simulation
     * Author: Luca Deltodesco
     *
     * In this sample, I show how to construct the most basic of Nape
     * simulations, together with a debug display.
     *
     */
 
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
	import nape.constraint.Constraint;
	import nape.geom.GeomPoly;
	import nape.phys.Compound;
 
    import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyType;
	import nape.phys.Material;
    import nape.shape.Circle;
    import nape.shape.Polygon;
    import nape.space.Space;
    import nape.util.BitmapDebug;
    import nape.util.Debug;
	import nape.constraint.*;
	import nape.dynamics.InteractionFilter;
 
    public class Main extends Sprite {
 
		private var space:Space;
		private var debug:BitmapDebug;
		
		private var _body_1:Body;
		private var _body_2:Body;
		private var _body_3:Body;
		
		private var pivotJoint1:PivotJoint;
		private var pivotJoint2:PivotJoint;
		
        public function Main():void {
            super();
 
            if (stage != null) {
                initialise(null);
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, initialise);
            }
        }
 
        private function initialise(ev:Event):void {
            if (ev != null) {
                removeEventListener(Event.ADDED_TO_STAGE, initialise);
            }
 
            // Create a new simulation Space.
            //   Weak Vec2 will be automatically sent to object pool.
            //   when used as argument to Space constructor.
            var gravity:Vec2 = Vec2.weak(0, 600);
            space = new Space(gravity);
 
            // Create a new BitmapDebug screen matching stage dimensions and
            // background colour.
            //   The Debug object itself is not a DisplayObject, we add its
            //   display property to the display list.
            debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, 0xFFFFFF);
            addChild(debug.display);
             
            setUp();
 
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
 
        private function setUp():void {
            var w:int = stage.stageWidth;
            var h:int = stage.stageHeight;
			
			trace("width: " + w.toString());
			trace("height: " + h.toString());
 
            // Create the floor for the simulation.
            //   We use a STATIC type object, and give it a single
            //   Polygon with vertices defined by Polygon.rect utility
            //   whose arguments are (x, y) of top-left corner and the
            //   width and height.
            //
            //   A static object does not rotate, so we don't need to
            //   care that the origin of the Body (0, 0) is not in the
            //   centre of the Body's shapes.
            var floor:Body = new Body(BodyType.STATIC);
            floor.shapes.add(new Polygon(Polygon.box(2 * w, 10)));
			//floor.rotate(new Vec2(1, 0), -0.36);
			floor.position.setxy(0, h - 10);
            floor.space = space;
			
			var circle_radius:int = 15;
			var box_x:int = 400;
			var box_y:int = 40;
			var box_width:int = 100;
			var box_height:int = 40;
			var material:Material = new Material(0.5);

			//
			_body_1 = new Body(BodyType.DYNAMIC , new Vec2(box_x, box_y));
			_body_1.shapes.add(new Polygon(Polygon.box(box_width, box_height), material));
			//_body_1.userData = "Circle body";
			_body_1.space =  space;

			_body_2 = new Body(BodyType.DYNAMIC , new Vec2(box_x - 30, box_y + 25));
			_body_2.shapes.add(new Circle(circle_radius, null, material));
			//_body_2.userData = "Polygon body";
			_body_2.space = space;

			_body_3 = new Body(BodyType.DYNAMIC , new Vec2(box_y - 30, box_y + 25));
			_body_3.shapes.add(new Circle(circle_radius, null, material));
			//_body_2.userData = "Polygon body";
			_body_3.space = space;
			
			/*var ground:Body = new Body(BodyType.STATIC, new Vec2(w / 2, h - 50));
			ground.shapes.add(new Polygon(Polygon.box(w, 50), material));
			ground.space = space;*/
			
			var anchorBody_1:Vec2;
			var anchorBody_2:Vec2;
			
			anchorBody_1 = new Vec2(_body_1.localCOM.x - 30, _body_1.localCOM.y + 15);
			anchorBody_2 = new Vec2(_body_2.localCOM.x, _body_2.localCOM.y - 10);
			pivotJoint1 = new PivotJoint(_body_1, _body_2, anchorBody_1, anchorBody_2);
			//pivotJoint1.ignore = true;
			pivotJoint1.space = space;
			
			anchorBody_1 = new Vec2(_body_1.localCOM.x + 30, _body_1.localCOM.y + 15);
			anchorBody_2 = new Vec2(_body_3.localCOM.x, _body_3.localCOM.y - 10);
			pivotJoint2 = new PivotJoint(_body_1, _body_3, anchorBody_1, anchorBody_2);
			//pivotJoint2.ignore = true;
			pivotJoint2.space = space;
        }
 
        private function enterFrameHandler(ev:Event):void {
            // Step forward in simulation by the required number of seconds.
            space.step(1 / (stage.frameRate + 50));
 
            // Render Space to the debug draw.
            //   We first clear the debug screen,
            //   then draw the entire Space,
            //   and finally flush the draw calls to the screen.
            debug.clear();
            debug.draw(space);
            debug.flush();
        }
 
        private function keyDownHandler(ev:KeyboardEvent):void {
            if (ev.keyCode == 82) { // 'R'
                // space.clear() removes all bodies (and constraints of
                // which we have none) from the space.
                space.clear();
 
                setUp();
            }
        }
    }
	
}