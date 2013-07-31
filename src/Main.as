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
	import flash.ui.Keyboard;
	
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
		private var _temp:Body;
		
		private var pivotJoint1:PivotJoint;
		private var pivotJoint2:PivotJoint;
		
		private var _isHeroOnGround:Boolean = true;

		private var _heroSpeed:int = 20;

		//
		private var _isKeyPressed:Boolean = false;
		private var _keyPressed:uint = 0;
		
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
 
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyboardHandler);
            stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.addEventListener(Event.ENTER_FRAME, gameLoop);
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
			
			var wall_1:Body = new Body(BodyType.STATIC);
            wall_1.shapes.add(new Polygon(Polygon.box(10, h / 2)));
			wall_1.position.setxy(0, 3 * h / 4);
            wall_1.space = space;
			
			var wall_2:Body = new Body(BodyType.STATIC);
            wall_2.shapes.add(new Polygon(Polygon.box(10, h / 2)));
			wall_2.position.setxy(w - 2, 3 * h / 4);
            wall_2.space = space;
			
			var circle_radius:int = 20;
			var box_x:int = 400;
			var box_y:int = 240;
			var box_width:int = 50;
			var box_height:int = 10;
			var material:Material = new Material(0.5);

			//
			_body_1 = new Body(BodyType.DYNAMIC , new Vec2(box_x, box_y));
			_body_1.shapes.add(new Polygon(Polygon.box(box_width, box_height), material));
			//_body_1.userData = "Circle body";
			_body_1.space =  space;

			_body_2 = new Body(BodyType.DYNAMIC , new Vec2(box_x - 40, box_y));
			_body_2.shapes.add(new Circle(circle_radius, null, material));
			//_body_2.userData = "Polygon body";
			_body_2.space = space;

			_body_3 = new Body(BodyType.DYNAMIC , new Vec2(box_y + 40, box_y));
			_body_3.shapes.add(new Circle(circle_radius, null, material));
			//_body_2.userData = "Polygon body";
			_body_3.space = space;
			
			var anchorBody_1:Vec2;
			var anchorBody_2:Vec2;
			
			anchorBody_1 = new Vec2(_body_1.localCOM.x - 40, _body_1.localCOM.y);
			anchorBody_2 = new Vec2(_body_2.localCOM.x, _body_2.localCOM.y);
			pivotJoint1 = new PivotJoint(_body_1, _body_2, anchorBody_1, anchorBody_2);
			pivotJoint1.ignore = true;
			pivotJoint1.space = space;
			
			anchorBody_1 = new Vec2(_body_1.localCOM.x + 40, _body_1.localCOM.y);
			anchorBody_2 = new Vec2(_body_3.localCOM.x, _body_3.localCOM.y);
			pivotJoint2 = new PivotJoint(_body_1, _body_3, anchorBody_1, anchorBody_2);
			pivotJoint2.ignore = true;
			pivotJoint2.space = space;
        }
 
        private function enterFrameHandler(ev:Event):void {
            // Step forward in simulation by the required number of seconds.
            space.step(1 / (stage.frameRate + 50));
            gameLoop(ev);
            // Render Space to the debug draw.
            //   We first clear the debug screen,
            //   then draw the entire Space,
            //   and finally flush the draw calls to the screen.
            debug.clear();
            debug.draw(space);
            debug.flush();
        }
		
		private function keyboardHandler(event:KeyboardEvent):void
		{
			if (event.type == KeyboardEvent.KEY_DOWN)
			{
				_isKeyPressed = true;
				_keyPressed = event.keyCode;
			}
			else if (event.type == KeyboardEvent.KEY_UP)
			{
				 _isKeyPressed = false;
			}
		}

		/**
		 */
		private function gameLoop(event:Event):void
		{ 
			/*_randomTimeForNextPrize--;

			 if (_randomTimeForNextPrize <= 0)
			 {
				 _randomTimeForNextPrize = Math.random() * 1000;

				 addPrizeToScene();
			 }*/

			// РћР±СЂР°Р±РѕС‚РєР° РєР»Р°РІРёР°С‚СѓСЂС‹

			if (_isKeyPressed)
			{
				switch (_keyPressed)
				{
					case Keyboard.S:
					{
						if (_isHeroOnGround)
						{
							_body_2.velocity.x -= _heroSpeed;
						}

						break;
					}

					case Keyboard.W:
					{
						if (_isHeroOnGround)
						{
							_body_2.velocity.x += _heroSpeed;
						}

						break;
					}

					case Keyboard.A:
					{
						if (_isHeroOnGround)
						{
							_body_3.velocity.y = -_heroSpeed*7;
						}

						break;
					}

					case Keyboard.D:
					{
						if (_isHeroOnGround)
						{
							_body_3.velocity.y = +_heroSpeed*7;
						}

						break;
					}
					
					case Keyboard.SPACE:
					{
						if (_isHeroOnGround)
						{ trace("SPACE");
							_temp = _body_2;
							_body_2 = _body_3;
							_body_3 = _temp;
						}

						break;
					}
				}
			}
		}
    }
	
}