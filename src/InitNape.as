/**
 *
 */
package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import nape.constraint.PivotJoint;

	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.space.Broadphase;
	import nape.space.Space;
	import nape.util.ShapeDebug;

	/**
	 */
	public class InitNape extends Sprite
	{
		//
		private var _space:Space;
		private var _timeStep:Number = 1 / 30.0;
		private var _velocityIterations:int = 10;
		private var _positionIterations:int = 10;
		private var _gravity:Vec2;

		private var _appWidth:int = 800;
		private var _appHeight:int = 600;

		private var _debug:ShapeDebug;
		private var hand:PivotJoint;

		/**
		 */
		public function InitNape(appWidth:int = 800, appHeight:int = 600, timeStep:Number = 30, iterations:int = 10, gravity:Vec2 = null)
		{
			_appWidth = appWidth;
			_appHeight = appHeight;
			_timeStep = 1 / timeStep;
			_velocityIterations = _positionIterations = iterations;
			_gravity = ((gravity == null) ? new Vec2(0, 400) : gravity);

			init();
		}

		/**
		 */
		private function init(event:Event = null):void
		{
			_space = new Space(_gravity, Broadphase.SWEEP_AND_PRUNE);
			initDebugDraw();

			initHand();

			addEventListener(Event.ENTER_FRAME, enterFrameHandler)
		}

		/**
		 */
		private function initHand():void
		{
            hand = new PivotJoint(_space.world, _space.world, new Vec2(), new Vec2());
            hand.space = _space;
            hand.active = false;
            hand.stiff = false;

			addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void
			{
				stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			});
		}

		/**
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			var mp:Vec2 = new Vec2(event.stageX, event.stageY);
			var bodies:BodyList = _space.bodiesUnderPoint(mp);
			var body:Body;
		    for (var i:int = 0; i < bodies.length; i++)
		    {
			    body = bodies.at(i);
	            if(!body.isDynamic()) continue;

	            hand.body2 = body;
			    trace("mp: " + mp);
				trace("mp local: " + body.worldToLocal(mp));
	            hand.anchor2 = body.worldToLocal(mp);
	            hand.active = true;

	            break;
		    }
		}

		/**
		 */
		private function mouseUpHandler(event:MouseEvent):void
		{
			hand.active = false;
		}

		/**
		 */
		private function initDebugDraw():void
		{
			_debug = new ShapeDebug(_appWidth, _appHeight, 0xdddddd);
			_debug.thickness = 2;
//			_debug.drawCollisionArbiters = true;
			_debug.drawConstraints = true;
			_debug.drawConstraintErrors = true;
			_debug.drawConstraintSprings = false;
			addChild(_debug.display);
		}

		/**
		 */
		private function enterFrameHandler(event:Event):void
		{
			hand.anchor1.setxy(mouseX,mouseY);

			_space.step(_timeStep, _velocityIterations, _positionIterations);

			_debug.clear();
			_debug.draw(_space);
			_debug.flush();
		}

		/**
		 */
		public function space():Space
		{
			return _space;
		}

		/**
		 */
		public function clear():void
		{
			_space.clear();
			_space.gravity.set(_gravity);

			// re-add hand to space
			hand.space = _space;
			_enableHand = true;
		}

		private var _enableHand:Boolean = true;

		/**
		 */
		public function set enableHand(val:Boolean):void
		{
			if (hand.space && !val)
			{
				hand.space = null;
			}
			else if ((hand.space == null) && val)
			{
				hand.space = _space;
			}

			_enableHand = val;
		}

		public function get enableHand():Boolean
		{
			return _enableHand;
		}
	}
}
