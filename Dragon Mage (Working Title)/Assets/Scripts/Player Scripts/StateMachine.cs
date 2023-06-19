using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IState
{
    public string name { get; }
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
    public WallClimbingState wallClimbingState;
    public WallVaultingState wallVaultingState;
    public FireTacklingState fireTacklingState;
    public FormChangingState formChangingState;
    public FrozenControlState frozenControlState;
    public DamagedState damagedState;

    public StateMachine(PlayerCtrl player)
    {
        standingState = new StandingState(player);
        runningState = new RunningState(player);
        jumpingState = new JumpingState(player);
        fallingState = new FallingState(player);
        glidingState = new GlidingState(player);
        wallSlidingState = new WallSlidingState(player);
        wallClimbingState = new WallClimbingState(player);
        wallVaultingState = new WallVaultingState(player);
        fireTacklingState = new FireTacklingState(player);
        formChangingState = new FormChangingState(player);
        frozenControlState = new FrozenControlState(player);
        damagedState = new DamagedState(player);
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
        if (!PauseHandler.isPaused && CurrentState != null) { CurrentState.Update(); }
    }
}

/* STATES */
public abstract class State : IState
{
    protected PlayerCtrl player;
    public string name { get; protected set; }

    public State(PlayerCtrl player) { this.player = player; }

    public abstract void Enter();

    public abstract void Update();

    public abstract void Exit();

    protected bool CheckFormChangeInput()
    {
        if (player.form.CanFormChange())
        {
            player.stateMachine.TransitionTo(player.stateMachine.formChangingState);
            return true;
        }
        else if (player.form.CannotFormChange())
        {
            player.form.FormChangeFail();
        }
        else { }
        return false;
    }

    protected bool CheckRunInput()
    {
        if ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && (!player.collisions.IsAgainstWall || (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) < 0f) && player.inputVector.x != 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.runningState);
            return true;
        }
        return false;
    }

    protected bool CheckStationaryLanding()
    {
        if ((player.collisions.IsGrounded || player.collisions.IsOnASlope))
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
        player.attacks.UseAttack();
        if (player.attacks.isFireTackleActive)
        {
            if (!player.collisions.IsGrounded) { player.rb2d.gravityScale = (player.rb2d.velocity.y > 0f ? player.jumping.risingGravity : player.jumping.fallingGravity); }
            player.stateMachine.TransitionTo(player.stateMachine.fireTacklingState);
            return true;
        }
        return false;
    }

    protected bool CheckSuddenFall()
    {
        if (!player.collisions.IsGrounded && !player.collisions.IsOnASlope && player.buffers.coyoteTimeLeft <= 0f && player.rb2d.velocity.y <= 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }

    protected bool CheckSuddenRise()
    {
        if (!player.collisions.IsGrounded && !player.collisions.IsOnASlope && player.buffers.coyoteTimeLeft <= 0f && player.rb2d.velocity.y > 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.jumpingState);
            return true;
        }
        return false;
    }

    protected bool CheckSuddenMovement()
    {
        if (player.rb2d.velocity.x != 0f)
        {
            player.stateMachine.TransitionTo(player.stateMachine.runningState);
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

    protected bool CheckIfDamaged()
    {
        if (player.damage.isPlayerDamaged)
        {
            player.stateMachine.TransitionTo(player.stateMachine.damagedState);
            return true;
        }
        return false;
    }
}

public class StandingState : State
{
    public StandingState(PlayerCtrl player) : base(player) { name = "Standing"; }

    public override void Enter()
    {
        player.rb2d.isKinematic = true;
        player.rb2d.velocity = Vector2.zero;
        player.jumping.LandingReset();
        if (player.collisions.IsOnASlope) { player.collisions.SnapToGround(); }
    }

    public override void Update()
    {
        player.rb2d.velocity = Vector2.zero;
        if (CheckFormChangeInput() || CheckRunInput() || CheckJumpInput() || CheckFireTackleInput() || CheckSuddenRise() || CheckSuddenFall() || CheckSuddenMovement() || CheckIfDamaged()) { return; }
        player.animationCtrl.StandingAnimation();
    }

    public override void Exit()
    {
        player.rb2d.isKinematic = false;
    }
}

public class RunningState : State
{
    public RunningState(PlayerCtrl player) : base(player) { name = "Running"; }

    public override void Enter()
    {
        if (player.stateMachine.PreviousState == player.stateMachine.fallingState || player.stateMachine.PreviousState == player.stateMachine.jumpingState || player.stateMachine.PreviousState == player.stateMachine.wallClimbingState)
        {
            player.jumping.LandingReset();
        }
    }

    public override void Update()
    {
        player.movement.Movement();
        player.movement.FacingDirection();
        if (CheckFormChangeInput() || CheckIfStopped() || CheckSuddenFall() || CheckJumpInput() || CheckFireTackleInput() || CheckIfDamaged()) { return; }
        player.animationCtrl.RunningAnimation();
    }

    public override void Exit()
    {
        
    }

    private bool CheckIfStopped()
    {
        if ((player.collisions.IsAgainstWall && (player.inputVector.x * (player.movement.isFacingRight ? 1f : -1f)) > 0f) || (player.inputVector.x == 0f && player.rb2d.velocity.x == 0f))
        {
            player.stateMachine.TransitionTo(player.stateMachine.standingState);
            return true;
        }
        return false;
    }
}

public class JumpingState : State
{
    public JumpingState(PlayerCtrl player) : base(player) { name = "Jumping"; }

    public override void Enter()
    {
        
    }

    public override void Update()
    {
        player.movement.Movement();
        player.movement.FacingDirection();
        player.jumping.GroundJumpUpdate();
        if (CheckFormChangeInput() || CheckFireTackleInput() || CheckIfWallClimbing() || CheckIfWallSliding() || CheckGlideInput() || CheckMidairJumpInput() || CheckIfFalling() || CheckIfGrounded() || CheckIfDamaged()) { return; }
    }

    public override void Exit()
    {

    }

    private bool CheckIfGrounded()
    {
        if ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && (player.rb2d.velocity.y >= -0.001f && player.rb2d.velocity.y <= 0.001f))
        {
            player.stateMachine.TransitionTo(player.rb2d.velocity.x == 0f ? player.stateMachine.standingState : player.stateMachine.runningState);
            return true;
        }
        return false;
    }

    private bool CheckIfFalling()
    {
        if (player.rb2d.velocity.y <= player.collisions.GetRightVector().y)
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }
}

public class FallingState : State
{
    public FallingState(PlayerCtrl player) : base(player) { name = "Falling"; }

    public override void Enter()
    {
        player.jumping.jumpIsHeld = false;
        player.rb2d.gravityScale = player.jumping.fallingGravity;
    }

    public override void Update()
    {
        player.movement.Movement();
        player.movement.FacingDirection();
        player.jumping.FallingUpdate();
        if (CheckFormChangeInput() || CheckFireTackleInput() || CheckRunInput() || CheckStationaryLanding() || CheckJumpInput() || CheckIfWallClimbing() || CheckIfWallSliding() || CheckGlideInput() || CheckMidairJumpInput() || CheckIfDamaged()) { return; }
        player.animationCtrl.FallingAnimation();
    }

    public override void Exit()
    {

    }
}

public class GlidingState : State
{
    public GlidingState(PlayerCtrl player) : base(player) { name = "Gliding"; }

    public override void Enter()
    {
        player.jumping.GlideStart();
    }

    public override void Update()
    {
        player.movement.Movement();
        player.jumping.GlideUpdate();
        if (CheckFormChangeInput() || CheckFireTackleInput() || CheckIfWallSliding() || CheckGlideCancel() || CheckIfDamaged()) { return; }
        player.animationCtrl.GlidingAnimation();
    }

    public override void Exit()
    {
        player.jumping.GlideCancel();
    }

    private bool CheckGlideCancel()
    {
        if (!player.jumpButtonHeld || player.collisions.IsGrounded || player.jumping.currentAirStallTime >= player.jumping.maxAirStallTime)
        {
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }
}

public class WallSlidingState : State
{
    public WallSlidingState(PlayerCtrl player) : base(player) { name = "WallSliding"; }

    public override void Enter()
    {
        player.jumping.WallSlideStart();
    }

    public override void Update()
    {
        player.jumping.WallSlideUpdate();
        if (CheckFormChangeInput() || CheckFireTackleInput() || CheckIfWallJumping() || CheckWallSlideCancel() || CheckIfDamaged()) { return; }
        player.animationCtrl.WallSlidingAnimation();
    }

    public override void Exit()
    {

    }

    private bool CheckIfWallJumping()
    {
        if (player.jumping.CanWallJump())
        {
            player.jumping.WallJumpStart();
            player.stateMachine.TransitionTo(player.stateMachine.jumpingState);
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

public class WallClimbingState : State
{
    public WallClimbingState(PlayerCtrl player) : base(player) { name = "WallClimbing"; }

    public override void Enter()
    {
        player.jumping.WallClimbStart();
    }

    public override void Update()
    {
        player.jumping.WallClimbUpdate();
        if (CheckFormChangeInput() || CheckFireTackleInput() || CheckLedgeSnap() || CheckWallVault() || CheckWallClimbCancel() || CheckIfDamaged()) { return; }
        player.animationCtrl.WallClimbingAnimation();
    }

    public override void Exit()
    {
        player.jumping.WallClimbEnd();
    }

    private bool CheckLedgeSnap()
    {
        if (player.jumping.CanStartWallVault() && player.technicalButtonHeld)
        {
            player.jumping.LedgeSnap();
            player.stateMachine.TransitionTo(player.stateMachine.runningState);
            return true;
        }
        return false;
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
    public WallVaultingState(PlayerCtrl player) : base(player) { name = "WallVaulting"; }

    public override void Enter()
    {
        player.jumping.WallVaultStart();
    }

    public override void Update()
    {
        player.jumping.WallVaultUpdate();
        if (CheckFormChangeInput() || CheckFireTackleInput() || CheckWallVaultDash() || CheckWallVaultCancel() || CheckIfDamaged()) { return; }
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
            player.jumping.WallClimbCancel();
            player.stateMachine.TransitionTo(player.stateMachine.fallingState);
            return true;
        }
        return false;
    }
}

public class FireTacklingState : State
{
    public FireTacklingState(PlayerCtrl player) : base(player) { name = "FireTackling"; }

    public override void Enter()
    {
        
    }

    public override void Update()
    {
        if (CheckFireTackleFinished()) { return; }
    }

    public override void Exit()
    {

    }

    private bool CheckFireTackleFinished()
    {
        if (!player.attacks.isFireTackleActive)
        {
            State nextState;
            if (player.damage.isPlayerDamaged) { nextState = player.stateMachine.damagedState; }
            else if (player.temper.forceFormChange) { nextState = player.stateMachine.formChangingState; }
            else if (player.jumping.CanWallClimb()) { nextState = player.stateMachine.wallClimbingState; }
            else if (player.attacks.isFireTackleEndlagCanceled) { player.jumping.GroundJumpStart(); nextState = player.stateMachine.jumpingState; }
            else if ((player.collisions.IsGrounded || player.collisions.IsOnASlope) && (player.inputVector.x != 0f || player.rb2d.velocity.x != 0f)) { nextState = player.stateMachine.runningState; }
            else if (player.rb2d.velocity.y > 0f && !(player.collisions.IsGrounded || player.collisions.IsOnASlope)) { nextState = player.stateMachine.jumpingState; }
            else if (player.rb2d.velocity.y <= 0f && !(player.collisions.IsGrounded || player.collisions.IsOnASlope)) { nextState = player.stateMachine.fallingState; }
            else { nextState = player.stateMachine.standingState; }

            player.stateMachine.TransitionTo(nextState);
            return true;
        }
        return false;
    }
}

public class FormChangingState : State
{
    public FormChangingState(PlayerCtrl player) : base(player) { name = "FormChanging"; }

    public override void Enter()
    {
        player.form.FormChange();
    }

    public override void Update()
    {
        if (!player.form.isChangingForm)
        {
            switch (player.stateMachine.PreviousState.name)
            {
                case "Gliding":
                    player.stateMachine.TransitionTo(player.stateMachine.fallingState);
                    break;
                case "WallSliding":
                    player.stateMachine.TransitionTo((player.jumping.CanWallClimb() ? player.stateMachine.wallClimbingState : player.stateMachine.fallingState));
                    break;
                case "WallClimbing":
                    player.stateMachine.TransitionTo((player.jumping.CanWallSlide() ? player.stateMachine.wallSlidingState : player.stateMachine.fallingState));
                    break;
                case "WallVaulting":
                    player.stateMachine.TransitionTo((player.rb2d.velocity.y > 0f ? player.stateMachine.jumpingState : player.stateMachine.fallingState));
                    break;
                case "Jumping":
                    player.stateMachine.TransitionTo(player.stateMachine.PreviousState);
                    player.animationCtrl.GroundJumpAnimation();
                    break;
                case "Damaged":
                    player.stateMachine.TransitionTo(player.stateMachine.standingState);
                    break;
                default:
                    player.stateMachine.TransitionTo(player.stateMachine.PreviousState);
                    break;
            }
        }
    }

    public override void Exit()
    {

    }
}

public class FrozenControlState : State
{
    public FrozenControlState(PlayerCtrl player) : base(player) { name = "FrozenControl"; }

    public override void Enter()
    {
        player.rb2d.velocity = Vector2.zero;
        player.rb2d.isKinematic = true;
        player.animationCtrl.StandingAnimation();
    }

    public override void Update()
    {
        player.rb2d.velocity = Vector2.zero;
        if (!player.areControlsFrozen) { player.stateMachine.TransitionTo(player.stateMachine.PreviousState); }
    }

    public override void Exit()
    {
        player.rb2d.isKinematic = false;
    }
}

public class DamagedState : State
{
    public DamagedState(PlayerCtrl player) : base(player) { name = "Damaged"; }

    public override void Enter()
    {
        player.rb2d.isKinematic = false;
        player.rb2d.gravityScale = player.jumping.fallingGravity;
        player.animationCtrl.DamageAnimation(player.form.currentMode);
        player.damage.DoKnockback();
    }

    public override void Update()
    {
        if (!player.damage.isPlayerDamaged)
        {
            State nextState;
            if (player.temper.forceFormChange) { nextState = player.stateMachine.formChangingState; }
            else { nextState = player.stateMachine.standingState; }

            player.stateMachine.TransitionTo(nextState);
        }
    }

    public override void Exit()
    {
        player.damage.DoIFrames();
    }
}
