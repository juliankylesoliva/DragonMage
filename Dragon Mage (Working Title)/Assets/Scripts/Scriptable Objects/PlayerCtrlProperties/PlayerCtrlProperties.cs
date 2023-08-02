using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "PlayerCtrlProperties", menuName = "ScriptableObjects/PlayerCtrlProperties", order = 1)]
public class PlayerCtrlProperties : ScriptableObject
{
    /* RUNNING VARIABLES */
    [Header("Running Variables")]
    [SerializeField] float _acceleration = 0.5f;
    public float acceleration { get { return _acceleration; } }

    [SerializeField] float _deceleration = 0.5f;
    public float deceleration { get { return _deceleration; } }

    [SerializeField] float _topSpeed = 18f;
    public float topSpeed { get { return _topSpeed; } }

    [SerializeField] float _turningSpeed = 0.5f;
    public float turningSpeed { get { return _turningSpeed; } }

    /* JUMPING VARIABLES */
    [Header("Jumping Variables")]
    [SerializeField] bool _changeFacingDirectionMidair = true;
    public bool changeFacingDirectionMidair { get { return _changeFacingDirectionMidair; } }

    [SerializeField] bool _enableSpeedHopping = true;
    public bool enableSpeedHopping { get { return _enableSpeedHopping; } }

    [SerializeField] float _jumpSpeed = 4f;
    public float jumpSpeed { get { return _jumpSpeed; } }

    [SerializeField] float _risingGravity = 1f;
    public float risingGravity { get { return _risingGravity; } }

    [SerializeField] float _fallingGravity = 1f;
    public float fallingGravity { get { return _fallingGravity; } }

    [SerializeField] float _fallSpeed = 6f;
    public float fallSpeed { get { return _fallSpeed; } }

    [SerializeField] float _airAcceleration = 0.5f;
    public float airAcceleration { get { return _airAcceleration; } }

    [SerializeField] float _airDeceleration = 0.5f;
    public float airDeceleration { get { return _airDeceleration; } }

    [SerializeField] float _airTurningSpeed = 0.5f;
    public float airTurningSpeed { get { return _airTurningSpeed; } }

    [Header("Variable Jump Variables")]
    [SerializeField] bool _enableVariableJumps = true;
    public bool enableVariableJumps { get { return _enableVariableJumps; } }

    [SerializeField] float _minJumpHoldTime = 0.1f;
    public float minJumpHoldTime { get { return _minJumpHoldTime; } }

    [SerializeField] float _variableJumpDecay = 0.5f;
    public float variableJumpDecay { get { return _variableJumpDecay; } }

    [Header("Air Stalling Variables")]
    [SerializeField] bool _enableAirStalling = true;
    public bool enableAirStalling { get { return _enableAirStalling; } }

    [SerializeField] float _minimumAirStallHeight = 1f;
    public float minimumAirStallHeight { get { return _minimumAirStallHeight; } }

    [SerializeField] float _airStallSpeed = 1f;
    public float airStallSpeed { get { return _airStallSpeed; } }

    [SerializeField, Range(0f, 5f)] float _maxAirStallTime = 3f;
    public float maxAirStallTime { get { return _maxAirStallTime; } }

    [Header("Wall Climb Variables")]
    [SerializeField] bool _enableWallClimbing = true;
    public bool enableWallClimbing { get { return _enableWallClimbing; } }

    [SerializeField] float _minimumWallClimbHeight = 1f;
    public float minimumWallClimbHeight { get { return _minimumWallClimbHeight; } }

    [SerializeField] float _baseClimbingSpeed = 4f;
    public float baseClimbingSpeed { get { return _baseClimbingSpeed; } }

    [SerializeField] float _maxClimbingSpeed = 12f;
    public float maxClimbingSpeed { get { return _maxClimbingSpeed; } }

    [SerializeField] float _climbingGravity = 0.25f;
    public float climbingGravity { get { return _climbingGravity; } }

    [SerializeField] float _maxWallClimbTime = 3f;
    public float maxWallClimbTime { get { return _maxWallClimbTime; } }

    [SerializeField] float _ledgeSnapDistance = 0.35f;
    public float ledgeSnapDistance { get { return _ledgeSnapDistance; } }

    [SerializeField] float _postClimbDashWindow = 1f;
    public float postClimbDashWindow { get { return _postClimbDashWindow; } }

    [SerializeField] float _wallVaultStartSpeed = 3f;
    public float wallVaultStartSpeed { get { return _wallVaultStartSpeed; } }

    [SerializeField] float _maxWallVaultStartSpeed = 6f;
    public float maxWallVaultStartSpeed { get { return _maxWallVaultStartSpeed; } }

    [Header("Wall Jump Variables")]
    [SerializeField] bool _enableWallJumping = true;
    public bool enableWallJumping { get { return _enableWallJumping; } }

    [SerializeField] float _minimumWallJumpHeight = 1f;
    public float minimumWallJumpHeight { get { return _minimumWallJumpHeight; } }

    [SerializeField] float _wallSlideSpeed = 1f;
    public float wallSlideSpeed { get { return _wallSlideSpeed; } }

    [SerializeField] float _verticalWallJumpSpeed = 4f;
    public float verticalWallJumpSpeed { get { return _verticalWallJumpSpeed; } }

    [SerializeField] float _horizontalWallJumpSpeed = 6f;
    public float horizontalWallJumpSpeed { get { return _horizontalWallJumpSpeed; } }

    [SerializeField] float _wallJumpCooldown = 0.25f;
    public float wallJumpCooldown { get { return _wallJumpCooldown; } }

    [Header("Midair Jump Variables")]
    [SerializeField, Range(0, 5)] int _maxMidairJumps = 3;
    public int maxMidairJumps { get { return _maxMidairJumps; } }

    [SerializeField] float _midairJumpSpeed = 4.25f;
    public float midairJumpSpeed { get { return _midairJumpSpeed; } }

    [SerializeField] Vector2 _forwardMidairJumpBonus;
    public Vector2 forwardMidairJumpBonus { get { return _forwardMidairJumpBonus; } }

    [Header("Running Jump Variables")]
    [SerializeField] bool _enableRunningJumpBonus = true;
    public bool enableRunningJumpBonus { get { return _enableRunningJumpBonus; } }

    [SerializeField] float _runningJumpMultiplier = 1f;
    public float runningJumpMultiplier { get { return _runningJumpMultiplier; } }

    [Header("Crouching Variables")]
    [SerializeField] bool _enableCrouchWalking = false;
    public bool enableCrouchWalking { get { return _enableCrouchWalking; } }

    [SerializeField] float _crouchTopSpeed = 1f;
    public float crouchTopSpeed { get { return _crouchTopSpeed; } }

    [SerializeField] bool _enableCrouchJump = false;
    public bool enableCrouchJump { get { return _enableCrouchJump; } }

    [SerializeField] bool _enableSuperJump = false;
    public bool enableSuperJump { get { return _enableSuperJump; } }

    [SerializeField] float _superJumpChargeTime = 1f;
    public float superJumpChargeTime { get { return _superJumpChargeTime; } }

    [SerializeField] float _superJumpRetentionTime = 3f;
    public float superJumpRetentionTime { get { return _superJumpRetentionTime; } }

    [SerializeField] float _superJumpSpeedMultiplier = 1f;
    public float superJumpSpeedMultiplier { get { return _superJumpSpeedMultiplier; } }
}
