using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IState
{
    public void Enter();
    public void Update();
    public void Exit();
}

/* STATE MACHINE */
[System.Serializable]
public class StateMachine
{
    public IState CurrentState { get; private set; }

    public StandingState standingState;
    public RunningState runningState;
    public JumpingState jumpingState;
    public FallingState fallingState;
    //public GlidingState glidingState;
    public WallSlidingState wallSlidingState;
    //public WallJumpingState wallJumpingState;
    //public ClimbingState climbingState;
    //public WallVaultingState wallVaultingState;
    public AttackingState attackingState;
    //public FormChangingState formChangingState;

    public StateMachine(PlayerCtrl player)
    {
        standingState = new StandingState(player);
        runningState = new RunningState(player);
        jumpingState = new JumpingState(player);
        fallingState = new FallingState(player);
        //glidingState = new GlidingState(player);
        wallSlidingState = new WallSlidingState(player);
        //wallJumpingState = new WallJumpingState(player);
        //climbingState = new ClimbingState(player);
        //wallVaultingState = new WallVaultingState(player);
        attackingState = new AttackingState(player);
        //formChangingState = new FormChangingState(player);
    }

    public void Initialize(IState startingState)
    {
        CurrentState = startingState;
        startingState.Enter();
    }

    public void TransitionTo(IState nextState)
    {
        CurrentState.Exit();
        CurrentState = nextState;
        nextState.Enter();
    }

    public void Update()
    {
        if (CurrentState != null) { CurrentState.Update(); Debug.Log(CurrentState.GetType()); }
    }
}

/* STATES */
public abstract class State : IState
{
    protected PlayerCtrl player;

    public State(PlayerCtrl player) { this.player = player; }

    public abstract void Enter();

    public abstract void Update();

    public abstract void Exit();

    protected bool CheckJumpInput()
    {
        if (((player.collisions.IsGrounded || player.buffers.coyoteTimeLeft > 0f) && player.buffers.jumpBufferTimeLeft > 0f))
        {
            player.buffers.jumpBufferTimeLeft = 0f;
            player.jumpIsHeld = true;
            player.rb2d.gravityScale = player.risingGravity;

            float horizontalResult = (player.enableSpeedHopping && (player.rb2d.velocity.x * Input.GetAxisRaw("Horizontal")) > 0f && Mathf.Abs(player.rb2d.velocity.x) >= player.movement.topSpeed && player.buffers.highestSpeedBuffer > Mathf.Abs(player.rb2d.velocity.x) ? (player.buffers.highestSpeedBuffer * Input.GetAxisRaw("Horizontal")) : player.rb2d.velocity.x);
            player.rb2d.velocity = new Vector2(horizontalResult, player.jumpSpeed + (player.enableRunningJumpBonus ? Mathf.Abs(horizontalResult / player.movement.topSpeed) * player.runningJumpMultiplier : 0f));

            player.stateMachine.TransitionTo(player.stateMachine.jumpingState);
            return true;
        }
        return false;
    }

    protected bool CheckFireTackleInput()
    {
        if (player.currentMode == CharacterMode.DRAGON && !player.isAttackCooldownActive && Input.GetButtonDown("Attack"))
        {
            player.stateMachine.TransitionTo(player.stateMachine.attackingState);
            return true;
        }
        return false;
    }

    protected bool CheckSuddenFall()
    {
        if (!player.collisions.IsGrounded && player.buffers.coyoteTimeLeft < 0f && player.rb2d.velocity.y <= 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }

    protected bool CheckIfWallSliding()
    {
        if (player.enableWallJumping && player.collisions.CheckDistanceToGround(player.minimumWallJumpHeight) && !player.collisions.IsGrounded && player.collisions.IsAgainstWall && (player.movement.isFacingRight ? (Input.GetAxisRaw("Horizontal") > 0f && player.collisions.IsTouchingWallR) : (Input.GetAxisRaw("Horizontal") < 0f && player.collisions.IsTouchingWallL)) && (!Input.GetButton("Jump") || !player.jumpIsHeld || player.rb2d.velocity.y < 0f))
        {
            player.stateMachine.TransitionTo(player.stateMachine.wallSlidingState);
            return true;
        }
        return false;
    }

    protected bool CheckIfWallJumping()
    {
        return false;
    }
}

public class StandingState : State
{
    public StandingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        
    }

    public override void Update()
    {
        if (CheckRunInput() || CheckJumpInput() || CheckFireTackleInput() || CheckSuddenFall()) { return; }
    }

    public override void Exit()
    {
        
    }

    private bool CheckRunInput()
    {
        if (player.collisions.IsGrounded && (!player.collisions.IsAgainstWall || (Input.GetAxisRaw("Horizontal") * (player.movement.isFacingRight ? 1f : -1f)) < 0f) && Input.GetAxisRaw("Horizontal") != 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.runningState);
            return true;
        }
        return false;
    }
}

public class RunningState : State
{
    public RunningState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        
    }

    public override void Update()
    {
        player.movement.Movement();
        player.movement.FacingDirection();
        if (CheckJumpInput() || CheckFireTackleInput() || CheckIfStopped()) { return; }
    }

    public override void Exit()
    {
        
    }

    private bool CheckIfStopped()
    {
        if ((player.collisions.IsAgainstWall && (Input.GetAxisRaw("Horizontal") * (player.movement.isFacingRight ? 1f : -1f)) > 0f) || (Input.GetAxisRaw("Horizontal") == 0f && player.rb2d.velocity.x == 0f))
        {
            player.stateMachine.TransitionTo(player.stateMachine.standingState);
            return true;
        }
        return false;
    }
}

public class JumpingState : State
{
    public JumpingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {

    }

    public override void Update()
    {
        player.movement.Movement();
        player.movement.FacingDirection();
        if (CheckIfWallSliding() || CheckIfFalling()) { return; }
    }

    public override void Exit()
    {

    }

    private bool CheckIfFalling()
    {
        if (player.rb2d.velocity.y < 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }
}

public class FallingState : State
{
    public FallingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {

    }

    public override void Update()
    {
        player.movement.Movement();
        player.movement.FacingDirection();
    }

    public override void Exit()
    {

    }
}

public class WallSlidingState : State
{
    public WallSlidingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        player.jumpIsHeld = false;
        player.rb2d.gravityScale = 0f;
        player.rb2d.velocity = new Vector2(0f, -player.wallSlideSpeed);
        if (player.currentAirStallTime > 0f) { player.currentAirStallTime = player.maxAirStallTime; }
    }

    public override void Update()
    {

    }

    public override void Exit()
    {

    }
}

public class AttackingState : State
{
    public AttackingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {

    }

    public override void Update()
    {

    }

    public override void Exit()
    {

    }
}
