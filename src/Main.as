package 
{	
	/**
     *
     * Author: Pavel Sha
     *
     * Физика мотоциклиста здесь.
     *
     */
 
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.TimerEvent;
    import flash.ui.Keyboard;
    import flash.utils.Timer;
					
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
          
        private var _centre:Vec2;
        
        private var _body_1:Body;
        private var _body_2:Body;
        private var _body_3:Body;
        private var _temp:Body;
          
        private var _pivotJoint1:PivotJoint;
        private var _pivotJoint2:PivotJoint;
          
        private var _comp:Compound;
          
        private var _isHeroOnGround:Boolean = true;
        private var _heroSpeed:int = 20;

        private var _isKeyPressed:Boolean = false;
        private var _keyPressed:uint = 0;
        
        private var timer:Timer;
        private var _invert:Boolean = false;
        
        private const TIME_ACTION:uint = 100;
        private const ANGLE_CENTRE:Number = 0.4;
		
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
            
            var gravity:Vec2 = Vec2.weak(0, 600);
            space = new Space(gravity);
 
            debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, 0xFFFFFF);
            addChild(debug.display);
            
            timer = new Timer(TIME_ACTION);
            
            setUp();
 
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
            stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            stage.addEventListener(Event.ENTER_FRAME, gameLoop);
            stage.addEventListener(TimerEvent.TIMER_COMPLETE, completeTimer);
        }
 
        private function setUp():void {
            var w:int = stage.stageWidth;
            var h:int = stage.stageHeight;
			
            trace("width: " + w.toString());
            trace("height: " + h.toString());
 
            var floor:Body = new Body(BodyType.STATIC);
            floor.shapes.add(new Polygon(Polygon.box(2 * w, 10)));
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

            _body_1 = new Body(BodyType.DYNAMIC , new Vec2(box_x, box_y));
            _body_1.shapes.add(new Polygon(Polygon.box(box_width, box_height), material));
            _body_1.space =  space; 

            _centre = new Vec2(_body_1.position.x, _body_1.position.y);
            
            _body_2 = new Body(BodyType.DYNAMIC , new Vec2(box_x - 40, box_y));
            _body_2.shapes.add(new Circle(circle_radius, null, material));
            _body_2.space = space;

            _body_3 = new Body(BodyType.DYNAMIC , new Vec2(box_y + 40, box_y));
            _body_3.shapes.add(new Circle(circle_radius, null, material));
            _body_3.space = space;
           
            var anchorBody_1:Vec2;
            var anchorBody_2:Vec2;
           
            anchorBody_1 = new Vec2(_body_1.localCOM.x - 40, _body_1.localCOM.y);
            anchorBody_2 = new Vec2(_body_2.localCOM.x, _body_2.localCOM.y);
            _pivotJoint1 = new PivotJoint(_body_1, _body_2, anchorBody_1, anchorBody_2);
            _pivotJoint1.ignore = true;
            _pivotJoint1.space = space;
           
              anchorBody_1 = new Vec2(_body_1.localCOM.x + 40, _body_1.localCOM.y);
            anchorBody_2 = new Vec2(_body_3.localCOM.x, _body_3.localCOM.y);
            _pivotJoint2 = new PivotJoint(_body_1, _body_3, anchorBody_1, anchorBody_2);
            _pivotJoint2.ignore = true;
            _pivotJoint2.space = space;
           
            _comp = new Compound();
            _body_1.compound = _comp; _body_2.compound = _comp; _body_3.compound = _comp;
            _pivotJoint1.compound = _comp; _pivotJoint2.compound = _comp;
            _comp.space = space;
        }
 
        private function enterFrameHandler(ev:Event):void {
            space.step(1 / (stage.frameRate + 50)); 
            
            debug.clear();
            debug.draw(space);
            debug.flush();
        }
        
        private function completeTimer(event:TimerEvent):void {
            _isKeyPressed = true;
            timer.start();
            
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

        private function gameLoop(event:Event):void {
            if (_isKeyPressed) {
                switch (_keyPressed) {
                    case Keyboard.S: { //83
                        if (_body_2) _body_2.velocity.x += _invert ? _heroSpeed : -_heroSpeed;
                        break;
                    }
                    case Keyboard.W: { //87
                        if (_body_2) _body_2.velocity.x += _invert ? -_heroSpeed : _heroSpeed;
                        break;
                    }
                    case Keyboard.A: { //65
                        if (_comp) _comp.rotate(new Vec2(_body_1.position.x, _body_1.position.y), -ANGLE_CENTRE); 
                        break;
                    }
                    case Keyboard.D: { //68
                        if (_comp) _comp.rotate(new Vec2(_body_1.position.x, _body_1.position.y), ANGLE_CENTRE);
                        break;
                    }
                    case Keyboard.SPACE: { //32
                        if (_body_2 && _body_3) {
                            _temp = _body_2;
                            _body_2 = _body_3;
                            _body_3 = _temp;
                            _invert = !_invert;
                        }
                        break;
                    }
                }
                _isKeyPressed = false; _keyPressed = 0;
            }
        }
    }	
}