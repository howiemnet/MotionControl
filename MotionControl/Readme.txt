
=================================================

Message protocol:

64 byte packet always.

/* ---- To devices: ---- */

byte  [0]: message type:
0: disable PID / motor
1: enable PID / motor
2: next frame data
3: (was start animation, but now deprecated)
4: (was stop animation, now deprecated)
5: go directly to position (use with care!)
6: reset position to zero
7: get parameters (for PID only)
8: set parameters (ditto) - parameter block detailed below
9: enable streaming (for PID tuner)
10: disable streaming
11: (stiction)
12: (stop stiction)
16: Get live data (for initial state use)


/* ---- live data block: ---- */

byte:
 [0]
 [1]
 [2] = device state - see DEVICE_STATE below
 [3] = buffer state - see BUFFER_STATE below
 [4] currentPos
 [8] requestedPos
[12] currentAccel
[16] currentError
[20] PID output
[..] etc

/* ---- DEVICE_STATE ---- */

#define STATE_MOTOR_OFF 0
#define STATE_MOTOR_ON_IDLE 1
#define STATE_MOTOR_ON_PLAYING_FRAME 2
#define STATE_MOTOR_OFF_OUT_OF_BOUNDS 3
#define STATE_MOTOR_OFF_RAN_OUT_OF_FRAMES 4
#define STATE_DOING_STICTION_CALIBRATION 5

/* ---- DEVICE_STATE ---- */

#define BUFFER_STATE_NEED_NEXT_FRAME 1
#define BUFFER_STATE_OK 0







=================================================

To do:

- animation protocol:
   - rather than start / stop animation,
   - just send packets.
   - so to start anim, just send the first packet
   - then respond to "next frame please" messages
- to stop: either stop sending packets or disable motor


- PID:
   - handle reset to zero (message 6)

- stepper:
   - check protocol implementation -
   - do we send delta or position?
   - position preferred but
   - need a way to reset position to zero (after homing)

- non-sim mode:
   - check message route

- sort out what gets sent to device
   - translation to




ExecutiveController

- oversees all
- handles interface through MainWindowViewController
- program state
- logging etc
- handles overall permission: what can the user do now?
- gives ChannelHandler broad commands:
  - go to positions blah
  - play animation on channels
  - stop
  - let channel X get commands from input Y (?)
- doesn't handle animation / comms at all
- all in main thread




ChannelHandler

- handles the channel bank
- provides UI data packets into a thread-safe queue
- handles messages to/from channels
- uses a number of sources to feed channels with: TrajectoryGenerator, MotionBrain, Homing, etc
-






CommsHandler

- handles SIMULATION mode - just pretends there's a load of devices connected

- handles matrix
- handles message queues
- enumerates devices after open (asks channelhandler for channel IDs from hardware IDs)



HardwareInterfaces [protocol]:
- handle bare comms
- do their own polling if necessary


trajectory generation
- we have: currentVelocity, currentPosition, targetPosition
- we need: accelRate / frames, coastRate / frames, decelRate / frames

- can calculate targetDirection, stoppingDistance, distanceToTarget


process:
- if heading in wrong direction, {


} else heading in right direction, so {

} else static, so {
      if distanceToTarget > 2 * distanceCoveredDuringMaxAcceleration {
            // we'll need a coasting period
      }

}

