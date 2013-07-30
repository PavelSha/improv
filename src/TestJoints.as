/**
 * Created with IntelliJ IDEA.
 * User: VirtualMaestro
 * Date: 21.03.12
 * Time: 11:36
 * To change this template use File | Settings | File Templates.
 */
package 
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;

	[SWF(width=400, height=300, backgroundColor=0xdddddd, frameRate=30)]
	public class TestJoints extends Sprite
	{
		static public const APP_WIDTH:int = 400;
		static public const APP_HEIGHT:int = 300;

		private var _core:InitNape;
		private var _frameRate:Number = 30.0;
		private var _gravity:Vec2 = new Vec2(0, 100);

		/**
		 */
		public function TestJoints(initNape:InitNape = null)
		{
			_core = initNape;

			if (_core == null)
			{
				_core = new InitNape(APP_WIDTH, APP_HEIGHT, _frameRate, 20, _gravity);
			}
			else
			{
				_core.space().gravity.set(_gravity);
			}

			addChild(_core);

			init();
		}

		private var _body_1:Body;
		private var _body_2:Body;

		/**
		 */
		private function init():void
		{
			createBodies();

			getTimer(createPivotJoint, 1000, true, 1);
		}

		/**
		 */
		private function createBodies():void
		{
			var circleRadius:int = 20;
			var boxSize:int = 20;
			var material:Material = new Material(0.5);

			//
			_body_1 = new Body(BodyType.DYNAMIC, new Vec2(APP_WIDTH / 2, 50));
			_body_1.shapes.add(new Circle(circleRadius, null, material));
			_body_1.userData = "Circle body";
			_body_1.space = _core.space();

			_body_2 = new Body(BodyType.DYNAMIC, new Vec2(APP_WIDTH / 2 + 100, 100));
			_body_2.shapes.add(new Polygon(Polygon.box(boxSize, boxSize), material));
			_body_2.userData = "Polygon body";
			_body_2.space = _core.space();

			var ground:Body = new Body(BodyType.STATIC, new Vec2(APP_WIDTH / 2, APP_HEIGHT - 50));
			ground.shapes.add(new Polygon(Polygon.box(APP_WIDTH, 50), material));
			ground.space = _core.space();
		}

		/**
		 */
		private var pivotJoint:PivotJoint;

		/**
		 */
		private function createPivotJoint(event:TimerEvent):void
		{
			//
			var anchorBody_1:Vec2 = new Vec2(_body_1.localCOM.x, _body_1.localCOM.y + 15);
			var anchorBody_2:Vec2 = new Vec2(_body_2.localCOM.x + 5, _body_2.localCOM.y - 5);
//			pivotJoint = new PivotJoint(_body_1, _body_2, anchorBody_1, anchorBody_2);
			pivotJoint = new PivotJoint(_body_2, _core.space().world, _body_2.localCOM, _body_2.position);
			pivotJoint.ignore = true;
			pivotJoint.stiff = true;
			pivotJoint.breakUnderError = true;
			pivotJoint.maxError = 1;
			pivotJoint.space = _core.space();

			//
			var pivotStatic:PivotJoint = new PivotJoint(_body_1, _core.space().world, _body_1.localCOM, new Vec2(APP_WIDTH / 2, APP_HEIGHT / 2));
			pivotStatic.stiff = false;
			pivotStatic.breakUnderForce = true;
			pivotStatic.maxForce = 3000;
			pivotStatic.frequency = 0.5;
			pivotStatic.damping = 0.0;
			pivotStatic.space = _core.space();

//			getTimer(deactivateJoint, 3000);
		}

		private function deactivateJoint(event:TimerEvent):void
		{
			_core.enableHand = !_core.enableHand;
			pivotJoint.active = !pivotJoint.active;
		}

		/**
		 */
		private function getTimer(handler:Function, delay:uint = 1000, autoStart:Boolean = true, repeatCount:int = 0):Timer
		{
			var timer:Timer = new Timer(delay, repeatCount);
			timer.addEventListener(TimerEvent.TIMER, handler);
			if (autoStart)
			{
				timer.start();
			}

			return timer;
		}
	}
}
