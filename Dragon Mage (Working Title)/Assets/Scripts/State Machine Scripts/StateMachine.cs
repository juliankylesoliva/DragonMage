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
    public IState PreviousState { get; private set; }

    public StandingState standingState;
    public RunningState runningState;
    public JumpingState jumpingState;
    public FallingState fallingState;
    public GlidingState glidingState;
    public WallSlidingState wallSlidingState;
    public WallJumpingState wallJumpingState;
    public WallClimbingState wallClimbingState;
    public WallVaultingState wallVaultingState;
    public AttackingState attackingState;
    public FormChangingState formChangingState;

    public StateMachine(PlayerCtrl player)
    {
        standingState = new StandingState(player);
        runningState = new RunningState(player);
        jumpingState = new JumpingState(player);
        fallingState = new FallingState(player);
        glidingState = new GlidingState(player);
        wallSlidingState = new WallSlidingState(player);
        wallJumpingState = new WallJumpingState(player);
        wallClimbingState = new WallClimbingState(player);
        wallVaultingState = new WallVaultingState(player);
        attackingState = new AttackingState(player);
        formChangingState = new FormChangingState(player);
    }

    public void Initialize(IState startingState)
    {
        CurrentState = startingState;
        startingState.Enter();
    }

    public void TransitionTo(IState nextState)
    {
        PreviousState = CurrentState;
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

    protected bool CheckRunInput()
    {
        if (player.collisions.IsGrounded && (!player.collisions.IsAgainstWall || (Input.GetAxisRaw("Horizontal") * (player.movement.isFacingRight ? 1f : -1f)) < 0f) && Input.GetAxisRaw("Horizontal") != 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.runningState);
            return true;
        }
        return false;
    }

    protected bool CheckStationaryLanding()
    {
        if (player.collisions.IsGrounded && player.rb2d.velocity == Vector2.zero)
        {
            player.stateMachine.TransitionTo(player.stateMachine.standingState);
            return true;
        }
        return false;
    }

    protected bool CheckJumpInput()
    {
        if (player.jumping.CanGroundJump())
        {
            player.jumping.GroundJumpStart();
            player.stateMachine.TransitionTo(player.stateMachine.jumpingState);
            return true;
        }
        return false;
    }

    protected bool CheckGlideInput()
    {
        if (player.jumping.CanGlide())
        {
            player.stateMachine.TransitionTo(player.stateMachine.glidingState);
            return true;
        }
        return false;
    }

    protected bool CheckMidairJumpInput()
    {
        if (player.jumping.CanMidairJump())
        {
            player.jumping.MidairJump();
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
        if (!player.collisions.IsGrounded && player.buffers.coyoteTimeLeft <= 0f && player.rb2d.velocity.y <= 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }

    protected bool CheckSuddenRise()
    {
        if (!player.collisions.IsGrounded && player.buffers.coyoteTimeLeft <= 0f && player.rb2d.velocity.y > 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.jumpingState);
            return true;
        }
        return false;
    }

    protected bool CheckIfWallSliding()
    {
        if (player.jumping.CanWallSlide())
        {
            player.stateMachine.TransitionTo(player.stateMachine.wallSlidingState);
            return true;
        }
        return false;
    }

    protected bool CheckIfWallClimbing()
    {
        if (player.jumping.CanWallClimb())
        {
            player.stateMachine.TransitionTo(player.stateMachine.wallClimbingState);
            return true;
        }
        return false;
    }
}

public class StandingState : State
{
    public StandingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        player.jumping.LandingReset();
    }

    public override void Update()
    {
        if (CheckRunInput() || CheckJumpInput() || CheckFireTackleInput() || CheckSuddenRise() || CheckSuddenFall()) { return; }
    }

    public override void Exit()
    {
        
    }
}

public class RunningState : State
{
    public RunningState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        player.jumping.LandingReset();
    }

    public override void Update()
    {
        player.movement.Movement();
        player.movement.FacingDirection();
        if (CheckIfStopped() || CheckSuddenFall() || CheckJumpInput() || CheckFireTackleInput()) { return; }
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
        player.jumping.GroundJumpUpdate();

        if (CheckMidairJumpInput() || CheckIfWallClimbing() || CheckIfWallSliding() || CheckIfFalling()) { return; }
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
        player.jumping.jumpIsHeld = false;
        player.rb2d.gravityScale = player.jumping.fallingGravity;
    }

    public override void Update()
    {
        player.movement.Movement();
        player.movement.FacingDirection();
        if (CheckGlideInput() || CheckMidairJumpInput() || CheckIfWallClimbing() || CheckIfWallSliding() || CheckRunInput() || CheckStationaryLanding()) { return; }
    }

    public override void Exit()
    {

    }
}

public class GlidingState : State
{
    public GlidingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        player.jumping.GlideStart();
    }

    public override void Update()
    {
        player.movement.Movement();
        player.jumping.GlideUpdate();
        if (CheckIfWallSliding() || CheckGlideCancel()) { return; }
    }

    public override void Exit()
    {
        player.jumping.GlideCancel();
    }

    private bool CheckGlideCancel()
    {
        if (!Input.GetButton("Jump") || player.jumping.currentAirStallTime >= player.jumping.maxAirStallTime)
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }
}

public class WallSlidingState : State
{
    public WallSlidingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        player.jumping.WallSlideStart();
    }

    public override void Update()
    {
        if (CheckIfWallJumping() || CheckWallSlideCancel()) { return; }
    }

    public override void Exit()
    {

    }

    private bool CheckIfWallJumping()
    {
        if (player.jumping.CanWallJump())
        {
            player.stateMachine.TransitionTo(player.stateMachine.wallJumpingState);
            return true;
        }
        return false;
    }

    private bool CheckWallSlideCancel()
    {
        if (player.jumping.IsWallSlideCanceled())
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }
}

public class WallJumpingState : State
{
    public WallJumpingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        player.jumping.WallJumpStart();
    }

    public override void Update()
    {
        player.jumping.GroundJumpUpdate();
        if (!player.jumping.isWallJumpCooldownActive)
        {
            player.stateMachine.TransitionTo((player.rb2d.velocity.y > 0f ? player.stateMachine.jumpingState : player.stateMachine.fallingState));
        }
    }

    public override void Exit()
    {

    }
}

public class WallClimbingState : State
{
    public WallClimbingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        player.jumping.WallClimbStart();
    }

    public override void Update()
    {
        player.jumping.WallClimbUpdate();
        if (CheckWallVault() || CheckWallClimbCancel()) { return; }
    }

    public override void Exit()
    {
        player.jumping.WallClimbEnd();
    }

    private bool CheckWallVault()
    {
        if (player.jumping.CanStartWallVault())
        {
            player.jumping.WallVaultStart();
            player.stateMachine.TransitionTo(player.stateMachine.wallVaultingState);
            return true;
        }
        return false;
    }

    private bool CheckWallClimbCancel()
    {
        if (player.jumping.IsWallClimbCanceled())
        {
            player.jumping.WallClimbCancel();
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }
}

public class WallVaultingState : State
{
    public WallVaultingState(PlayerCtrl player) : base(player) { }

    public override void Enter()
    {
        player.jumping.WallVaultStart();
    }

    public override void Update()
    {
        player.jumping.WallVaultUpdate();
        if (CheckWallVaultDash() || CheckWallVaultCancel()) { return; }
    }

    public override void Exit()
    {
        player.jumping.WallVaultEnd();
    }

    private bool CheckWallVaultDash()
    {
        if (player.jumping.CanWallVaultDash())
        {
            player.jumping.WallVaultDash();
            player.stateMachine.TransitionTo(player.stateMachine.jumpingState);
            return true;
        }
        return false;
    }

    private bool CheckWallVaultCancel()
    {
        if (player.jumping.IsWallVaultCanceled())
        {
            player.stateMachine.TransitionTo((player.rb2d.velocity.y > 0f ? player.stateMachine.jumpingState : player.stateMachine.fallingState));
            return true;
        }
        return false;
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

public class FormChangingState : State
{
    public FormChangingState(PlayerCtrl player) : base(player) { }

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
