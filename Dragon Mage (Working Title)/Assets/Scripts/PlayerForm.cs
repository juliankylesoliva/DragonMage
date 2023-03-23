using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum CharacterMode { MAGE, DRAGON }

public class PlayerForm : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] PlayerCtrlProperties mageProperties;
    [SerializeField] PlayerCtrlProperties dragonProperties;

    [SerializeField] CharacterMode startingMode = CharacterMode.MAGE;

    [SerializeField] float formChangeTime = 0.25f;
    [SerializeField] float formChangeCooldownTime = 0.1f;

    [HideInInspector] public CharacterMode currentMode = CharacterMode.MAGE;

    [HideInInspector] public bool isChangingForm = false;

    [HideInInspector] public bool isFormChangeCooldownActive = false;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Start()
    {
        ChangeMode(startingMode);
    }

    public bool CanFormChange()
    {
        return (!player.form.isFormChangeCooldownActive && !player.attacks.isAttackCooldownActive && !player.form.isChangingForm && !player.attacks.isBlastJumpActive && !player.attacks.isFireTackleActive && (player.temper.forceFormChange || (!player.temper.isFormLocked && player.buffers.formChangeBufferTimeLeft > 0f)));
    }

    public void FormChange()
    {
        if (player.temper.forceFormChange) { player.temper.FormLockTemperChange(); }

        player.buffers.formChangeBufferTimeLeft = 0f;

        StartCoroutine(FormFreeze());
        StartCoroutine(FormChangeCooldownCR());

        if (currentMode == CharacterMode.MAGE)
        {
            ChangeMode(CharacterMode.DRAGON);
            return;
        }

        if (currentMode == CharacterMode.DRAGON)
        {
            ChangeMode(CharacterMode.MAGE);
            return;
        }
    }

    private void SetCtrlProperties(PlayerCtrlProperties p)
    {
        player.movement.acceleration = p.acceleration;
        player.movement.deceleration = p.deceleration;
        player.movement.topSpeed = p.topSpeed;
        player.movement.turningSpeed = p.turningSpeed;

        player.movement.changeFacingDirectionMidair = p.changeFacingDirectionMidair;
        player.jumping.enableSpeedHopping = p.enableSpeedHopping;
        player.jumping.jumpSpeed = p.jumpSpeed;
        player.jumping.risingGravity = p.risingGravity;
        player.jumping.fallingGravity = p.fallingGravity;
        player.jumping.fallSpeed = p.fallSpeed;
        player.movement.airAcceleration = p.airAcceleration;
        player.movement.airDeceleration = p.airDeceleration;
        player.movement.airTurningSpeed = p.airTurningSpeed;

        player.jumping.enableVariableJumps = p.enableVariableJumps;
        player.jumping.variableJumpDecay = p.variableJumpDecay;

        player.jumping.enableAirStalling = p.enableAirStalling;
        player.jumping.minimumAirStallHeight = p.minimumAirStallHeight;
        player.jumping.airStallSpeed = p.airStallSpeed;
        player.jumping.maxAirStallTime = p.maxAirStallTime;

        if (player.jumping.enableAirStalling && player.jumping.currentAirStallTime > 0f && player.jumping.maxAirStallTime > 0f) { player.jumping.currentAirStallTime = player.jumping.maxAirStallTime; }

        player.jumping.enableWallClimbing = p.enableWallClimbing;
        player.jumping.minimumWallClimbHeight = p.minimumWallClimbHeight;
        player.jumping.baseClimbingSpeed = p.baseClimbingSpeed;
        player.jumping.maxClimbingSpeed = p.maxClimbingSpeed;
        player.jumping.climbingGravity = p.climbingGravity;
        player.jumping.maxWallClimbTime = p.maxWallClimbTime;
        player.jumping.postClimbDashWindow = p.postClimbDashWindow;
        player.jumping.wallVaultStartSpeed = p.wallVaultStartSpeed;
        player.jumping.maxWallVaultStartSpeed = p.maxWallVaultStartSpeed;

        if (player.jumping.enableWallClimbing)
        {
            if (player.jumping.currentWallClimbTime > 0f && player.jumping.maxWallClimbTime > 0f) { player.jumping.currentWallClimbTime = player.jumping.maxWallClimbTime; }
            if (player.jumping.storedWallClimbSpeed > 0f) { player.jumping.storedWallClimbSpeed = 0f; }
            if (player.jumping.postClimbDashTimeLeft > 0f) { player.jumping.postClimbDashTimeLeft = 0f; }
        }

        player.jumping.enableWallJumping = p.enableWallJumping;
        player.jumping.minimumWallJumpHeight = p.minimumWallJumpHeight;
        player.jumping.wallSlideSpeed = p.wallSlideSpeed;
        player.jumping.verticalWallJumpSpeed = p.verticalWallJumpSpeed;
        player.jumping.horizontalWallJumpSpeed = p.horizontalWallJumpSpeed;
        player.jumping.wallJumpCooldown = p.wallJumpCooldown;

        player.jumping.maxMidairJumps = p.maxMidairJumps;
        player.jumping.midairJumpSpeed = p.midairJumpSpeed;
        player.jumping.forwardMidairJumpBonus = p.forwardMidairJumpBonus;

        player.jumping.enableRunningJumpBonus = p.enableRunningJumpBonus;
        player.jumping.runningJumpMultiplier = p.runningJumpMultiplier;
    }

    public IEnumerator FormChangeCooldownCR()
    {
        if (!isFormChangeCooldownActive)
        {
            isFormChangeCooldownActive = true;
            yield return new WaitForSeconds(formChangeCooldownTime);
            isFormChangeCooldownActive = false;
        }
        yield break;
    }

    public void ChangeMode(CharacterMode mode)
    {
        SetCtrlProperties(mode == CharacterMode.MAGE ? mageProperties : dragonProperties);
        currentMode = mode;
        player.animationCtrl.StandingAnimation();
    }

    private IEnumerator FormFreeze()
    {
        isChangingForm = true;

        Vector2 prevVelocity = player.rb2d.velocity;

        player.rb2d.gravityScale = 0f;
        player.rb2d.velocity = Vector2.zero;

        yield return new WaitForSeconds(formChangeTime);

        player.rb2d.gravityScale = (prevVelocity.y > 0f ? player.jumping.risingGravity : player.jumping.fallingGravity);
        player.rb2d.velocity = prevVelocity;

        isChangingForm = false;
    }
}
