using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerCollisions : MonoBehaviour
{
    PlayerCtrl player;

    public Transform groundCheckObj;
    public Transform[] wallChecksR;
    public Transform[] wallChecksL;
    public Transform crouchedWallCheckR;
    public Transform crouchedWallCheckL;
    public Transform headbonkCheckObj;
    public Transform crouchedHeadbonkCheckObj;
    public Transform normalCheckR;
    public Transform normalCheckL;

    [SerializeField] float groundCheckRadius = 0.1f;
    [SerializeField] float wallCheckRadius = 0.1f;
    [SerializeField] float headbonkCheckRadius = 0.5f;
    [SerializeField] float headbonkSpeedThreshold = 0.25f;
    [SerializeField] float slopeCheckDistance = 1f;
    [SerializeField] float ledgeCheckOffset = 0.25f;
    [SerializeField] float ledgeCheckDepth = 0.85f;
    [SerializeField] float groundNormalXThreshold = 0.1f;
    [SerializeField] float uncrouchedYOffset = -0.25f;
    [SerializeField] float crouchedYOffset = -0.5f;
    [SerializeField] float uncrouchedHeight = 1.5f;
    [SerializeField] float crouchedHeight = 1f;
    [SerializeField] LayerMask intangibleWallLayer;
    [SerializeField] LayerMask groundLayer;
    [SerializeField] LayerMask slopeLayer;
    [SerializeField] LayerMask distanceCheckLayer;
    [SerializeField] LayerMask nonEnemyGroundLayer;
    [SerializeField] PhysicsMaterial2D noFriction;
    [SerializeField] PhysicsMaterial2D fullFriction;
    [SerializeField] int playerLayer = 3;
    [SerializeField] int[] enemyLayers;

    [SerializeField] private bool isGrounded = false;
    [SerializeField] private bool isAgainstWall = false;
    [SerializeField] private bool isTouchingWallR = false;
    [SerializeField] private bool isTouchingWallL = false;
    [SerializeField] private bool isIntangibleWall = false;
    [SerializeField] private bool isHeadbonking = false;
    [SerializeField] private bool isOnASlope = false;

    public bool IsGrounded { get { return isGrounded; } }
    public bool IsAgainstWall { get { return isAgainstWall; } }
    public bool IsTouchingWallR { get { return isTouchingWallR; } }
    public bool IsTouchingWallL { get { return isTouchingWallL; } }
    public bool IsIntangibleWall { get { return isIntangibleWall; } }
    public bool IsHeadbonking { get { return isHeadbonking; } }
    public bool IsOnASlope { get { return isOnASlope; } }

    private bool prevIsGrounded = true;
    private bool prevIsHeadbonking = true;

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
    }

    void Update()
    {
        EnemyIntangibilityCheck();
        ColliderCrouchUpdate();
        GroundCheck();
        SlopeCheck();
        if (player.movement.isCrouching) { CrouchedWallCheck(); }
        else { WallCheck(); }
        HeadbonkCheck();

        LandingSoundCheck();
        HeadbonkSoundCheck();

        prevIsGrounded = isGrounded;
        prevIsHeadbonking = isHeadbonking;
    }

    private void EnemyIntangibilityCheck()
    {
        foreach (int i in enemyLayers)
        {
            Physics2D.IgnoreLayerCollision(playerLayer, i, player.damage.isDamageInvulnerabilityActive || player.damage.isPlayerDamaged || player.attacks.isDodging);
        }
    }

    private void ColliderCrouchUpdate()
    {
        player.capsuleCollider.size = new Vector2(0.5f, (player.movement.isCrouching ? crouchedHeight : uncrouchedHeight));
        player.capsuleCollider.offset = new Vector2(0f, (player.movement.isCrouching ? crouchedYOffset : uncrouchedYOffset));
    }

    private void GroundCheck()
    {
        isGrounded = false;
        Collider2D[] colliders = Physics2D.OverlapCircleAll(groundCheckObj.position, groundCheckRadius, groundLayer);
        isGrounded = (colliders.Length > 0);
    }

    private void SlopeCheck()
    {
        isOnASlope = false;

        RaycastHit2D hit = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, slopeCheckDistance, slopeLayer);
        RaycastHit2D hit2 = Physics2D.Raycast(groundCheckObj.position, GetRightVector() * player.movement.GetFacingValue(), slopeCheckDistance, slopeLayer);
        isOnASlope = (hit.collider != null || hit2.collider != null);
        isGrounded = (isGrounded || isOnASlope);

        if (!player.damage.isPlayerDamaged) { player.rb2d.sharedMaterial = (isOnASlope && !(player.stateMachine.PreviousState.name == "Dodging" && player.rb2d.velocity != Vector2.zero) && player.inputVector.x == 0f ? fullFriction : noFriction); }
    }

    private void WallCheck()
    {
        isAgainstWall = false;
        isTouchingWallR = false;
        isTouchingWallL = false;
        isIntangibleWall = false;

        bool firstPass = true;
        foreach (Transform t in wallChecksR)
        {
            if (!isIntangibleWall)
            {
                Collider2D[] intangibleR = Physics2D.OverlapCircleAll(t.position, wallCheckRadius, intangibleWallLayer);
                isIntangibleWall = (intangibleR.Length > 0 && (!firstPass || !isOnASlope));
            }

            Collider2D[] collidersR = Physics2D.OverlapCircleAll(t.position, wallCheckRadius, groundLayer);
            isTouchingWallR = (collidersR.Length > 0 && (!firstPass || !isOnASlope));
            if (isTouchingWallR) { break; }
            firstPass = false;
        }

        firstPass = true;
        foreach (Transform t in wallChecksL)
        {
            if (!isIntangibleWall)
            {
                Collider2D[] intangibleL = Physics2D.OverlapCircleAll(t.position, wallCheckRadius, intangibleWallLayer);
                isIntangibleWall = (intangibleL.Length > 0 && (!firstPass || !isOnASlope));
            }

            Collider2D[] collidersL = Physics2D.OverlapCircleAll(t.position, wallCheckRadius, groundLayer);
            isTouchingWallL = (collidersL.Length > 0 && (!firstPass || !isOnASlope));
            if (isTouchingWallL) { break; }
            firstPass = false;
        }

        isAgainstWall = (player.movement.isFacingRight ? isTouchingWallR : isTouchingWallL);
    }

    private void CrouchedWallCheck()
    {
        isAgainstWall = false;
        isTouchingWallR = false;
        isTouchingWallL = false;
        isIntangibleWall = false;

        if (!isIntangibleWall)
        {
            Collider2D[] intangibleR = Physics2D.OverlapCircleAll(crouchedWallCheckR.position, wallCheckRadius, intangibleWallLayer);
            isIntangibleWall = (intangibleR.Length > 0 && !isOnASlope);
        }

        Collider2D[] collidersR = Physics2D.OverlapCircleAll(crouchedWallCheckR.position, wallCheckRadius, groundLayer);
        isTouchingWallR = (collidersR.Length > 0 && !isOnASlope);

        if (!isIntangibleWall)
        {
            Collider2D[] intangibleL = Physics2D.OverlapCircleAll(crouchedWallCheckL.position, wallCheckRadius, intangibleWallLayer);
            isIntangibleWall = (intangibleL.Length > 0 && !isOnASlope);
        }

        Collider2D[] collidersL = Physics2D.OverlapCircleAll(crouchedWallCheckL.position, wallCheckRadius, groundLayer);
        isTouchingWallL = (collidersL.Length > 0 && !isOnASlope);

        isAgainstWall = (player.movement.isFacingRight ? isTouchingWallR : isTouchingWallL);
    }

    private void HeadbonkCheck()
    {
        isHeadbonking = false;
        Collider2D[] colliders = Physics2D.OverlapCircleAll((player.movement.isCrouching ? crouchedHeadbonkCheckObj.position : headbonkCheckObj.position) + (Vector3.right * (1f / 32f) * (player.movement.isFacingRight ? 1f : -1f)), headbonkCheckRadius, groundLayer);
        isHeadbonking = (colliders.Length > 0);
    }

    private void LandingSoundCheck()
    {
        if (!prevIsGrounded && isGrounded)
        {
            player.effects.FootstepSound();
            GameObject tempObj = EffectFactory.SpawnEffect("LandingDust", GetSimpleGroundPoint());
            tempObj.transform.up = GetGroundNormal();
        }
    }

    private void HeadbonkSoundCheck()
    {
        if ((!prevIsHeadbonking && isHeadbonking) || (player.stateMachine.CurrentState.name == "Jumping" && player.rb2d.velocity.y > headbonkSpeedThreshold && isHeadbonking))
        {
            player.effects.HeadbonkEffect();
        }
    }

    public bool CheckDistanceToGround(float minDistance)
    {
        RaycastHit2D hit = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, Mathf.Infinity, distanceCheckLayer);
        return (hit.distance >= minDistance || hit.distance == 0f);
    }

    public bool CheckIfNearLedge()
    {
        RaycastHit2D hit = Physics2D.Raycast(groundCheckObj.position + ((player.rb2d.velocity.x != 0f ? (player.rb2d.velocity.x > 0f ? 1f : -1f) : player.movement.GetFacingValue()) * ledgeCheckOffset * Vector3.right), -Vector2.up, ledgeCheckDepth, nonEnemyGroundLayer);
        return hit.collider == null;
    }

    public Vector2 GetDirectGroundNormal()
    {
        RaycastHit2D hit2 = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, slopeCheckDistance, nonEnemyGroundLayer);
        if (hit2.collider != null && (hit2.normal.x < -groundNormalXThreshold || hit2.normal.x > groundNormalXThreshold)) { return hit2.normal; }
        return Vector2.up;
    }

    public Vector2 GetGroundNormal()
    {
        RaycastHit2D hit = Physics2D.Raycast((player.movement.isFacingRight ? normalCheckR : normalCheckL).position, -Vector2.up, slopeCheckDistance, nonEnemyGroundLayer);
        if (hit.collider != null && (hit.normal.x < -groundNormalXThreshold || hit.normal.x > groundNormalXThreshold)) { return hit.normal; }
        else
        {
            RaycastHit2D hit2 = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, slopeCheckDistance, nonEnemyGroundLayer);
            if (hit2.collider != null && (hit2.normal.x < -groundNormalXThreshold || hit2.normal.x > groundNormalXThreshold)) { return hit2.normal; }
        }
        return Vector2.up;
    }

    public Vector2 GetCeilingNormal()
    {
        RaycastHit2D hit = Physics2D.Raycast(headbonkCheckObj.position, Vector2.up, headbonkCheckRadius, nonEnemyGroundLayer);
        if (hit.collider != null) { return hit.normal; }
        return -Vector2.up;
    }

    public Vector2 GetRightVector(bool direct = false)
    {
        Vector2 normal = (direct ? GetDirectGroundNormal() : GetGroundNormal());
        if (normal.y != 0f)
        {
            Vector2 result = -Vector2.Perpendicular(normal).normalized;
            float facingToNormalX = (normal.x * (player.movement.isFacingRight ? 1f : -1f));
            return result;
        }
        return Vector2.right;
    }

    public Vector2 GetClosestGroundPoint()
    {
        RaycastHit2D hit = Physics2D.Raycast(groundCheckObj.position, -Vector2.up, Mathf.Infinity, nonEnemyGroundLayer);
        if (hit.collider != null) { return hit.point; }
        return groundCheckObj.position;
    }

    public Vector3 GetSimpleGroundPoint()
    {
        return (groundCheckObj.position - (Vector3.up * (groundCheckRadius / 2f)));
    }

    public Vector3 GetSimpleCeilingPoint()
    {
        return ((player.movement.isCrouching ? crouchedHeadbonkCheckObj.position : headbonkCheckObj.position) + (Vector3.up * (headbonkCheckRadius / 2f)));
    }

    public void SnapToGround(bool bypassDistanceCheck, bool addGroundCheckDistance, float maxDistance = -1f)
    {
        Vector2 toMove = GetClosestGroundPoint();
        toMove += new Vector2(0f, Vector3.Distance(this.transform.position, groundCheckObj.position) + (addGroundCheckDistance ? groundCheckRadius : 0f));
        if (bypassDistanceCheck || (Vector2.Distance(this.transform.position, toMove) <= (maxDistance >= 0f ? maxDistance : slopeCheckDistance))) { this.transform.position = toMove; }
        GroundCheck();
    }

    public bool IsCeilingAboveWhenUncrouched()
    {
        RaycastHit2D hit = Physics2D.Raycast(crouchedHeadbonkCheckObj.position, Vector3.up, (headbonkCheckObj.position.y - crouchedHeadbonkCheckObj.position.y), nonEnemyGroundLayer);
        return (hit.collider != null);
    }
}
