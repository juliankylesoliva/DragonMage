using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AttackReticle : MonoBehaviour
{
    private const float HALF_ACCELERATION = 0.5f;
    private const float SECONDS_SQUARED = 2f;
    private const float AIRTIME_MULTIPLIER = 2f;

    SpriteRenderer spriteRenderer;

    // [SerializeField] LayerMask groundDetectionLayers;
    [SerializeField] float groundDetectionRadius = 0.05f;

    [SerializeField] SpriteRenderer reticleTrail;
    [SerializeField] float trailSpeed = 5f;

    [SerializeField] Sprite magicBlastTrail;
    [SerializeField] Sprite magicBlastReticle;

    [SerializeField] float verticalLaunchSpeed = 1f;
    [SerializeField] float verticalLaunchWithVerticalAxisUpModifier = 5f;
    [SerializeField] float verticalLaunchWithVerticalAxisDownModifier = -0.5f;
    [SerializeField] float verticalInertiaModifier = 0.25f;

    [SerializeField] float horizontalLaunchSpeed = 2f;
    [SerializeField] float horizontalLaunchWithVerticalAxisModifier = 0.25f;
    [SerializeField] float horizontalInertiaModifier = 0.5f;

    [SerializeField] float gravityScale = 2f;

    [SerializeField] float midairProjectileTime = 0.5f;

    [SerializeField] Sprite fireTackleTrail;
    [SerializeField] Sprite fireTackleReticle;

    private float currentTrailPosition = 0f;
    

    void Awake()
    {
        spriteRenderer = this.gameObject.GetComponent<SpriteRenderer>();
    }

    void Start()
    {
        
    }

    public void SetMagicBlastReticle(Vector3 initialPos, Vector3 groundPos, Vector2 playerVelocity, bool isGoingRight, float verticalAxis, bool isInMidair)
    {
        Vector2 initialSpeed = GetInitialProjectileVelocity(playerVelocity, isGoingRight, verticalAxis);

        float gravityAcceleration = Mathf.Abs(Physics2D.gravity.y * gravityScale);
        float airTime = (isInMidair ? midairProjectileTime : (verticalAxis < 0f ? Mathf.Sqrt(Mathf.Abs((groundPos.y - initialPos.y) / (HALF_ACCELERATION * gravityAcceleration))) : ((verticalAxis > 0f ? 1f : AIRTIME_MULTIPLIER) * (initialSpeed.y / gravityAcceleration))));

        Vector3 finalPos = (initialPos + ((Vector3)initialSpeed * airTime) + ((Vector3)Physics2D.gravity * gravityScale * HALF_ACCELERATION * Mathf.Pow(airTime, SECONDS_SQUARED)));
        this.transform.position = finalPos;

        reticleTrail.sprite = magicBlastTrail;
        spriteRenderer.sprite = magicBlastReticle;

        Vector3 trailPos = (initialPos + ((Vector3)initialSpeed * airTime * currentTrailPosition) + ((Vector3)Physics2D.gravity * gravityScale * HALF_ACCELERATION * Mathf.Pow(airTime * currentTrailPosition, SECONDS_SQUARED)));
        Vector2 trailVec = (trailPos - initialPos);
        reticleTrail.transform.position = trailPos;
        reticleTrail.transform.up = trailVec;

        UpdateTrailPosition();
    }

    public void SetFireTackleReticle(Vector3 initialPos, Vector2 fwdAndDownVelocity, float upAcceleration, float activeTime)
    {
        Vector3 finalPos = (initialPos + ((Vector3)fwdAndDownVelocity * activeTime) + (Vector3.up * upAcceleration * HALF_ACCELERATION * Mathf.Pow(activeTime, SECONDS_SQUARED)));
        this.transform.position = finalPos;

        reticleTrail.sprite = fireTackleTrail;
        spriteRenderer.sprite = fireTackleReticle;

        Vector3 trailPos = (initialPos + ((Vector3)fwdAndDownVelocity * activeTime * currentTrailPosition) + (Vector3.up * upAcceleration * HALF_ACCELERATION * Mathf.Pow(activeTime * currentTrailPosition, SECONDS_SQUARED)));
        Vector2 trailVec = (trailPos - initialPos);
        reticleTrail.transform.position = trailPos;
        reticleTrail.transform.up = trailVec;

        UpdateTrailPosition();
    }

    public void UpdateTrailPosition()
    {
        currentTrailPosition += (Time.deltaTime * trailSpeed);
        if (currentTrailPosition >= 1f) { currentTrailPosition -= 1f; }
    }

    public void ResetTrailPosition()
    {
        currentTrailPosition = 0f;
    }

    private Vector2 GetInitialProjectileVelocity(Vector2 playerVelocity, bool isGoingRight, float verticalAxis)
    {
        float horizontalResult = ((isGoingRight ? horizontalLaunchSpeed : -horizontalLaunchSpeed) * (verticalAxis != 0f ? horizontalLaunchWithVerticalAxisModifier : 1f));
        float verticalResult = (verticalLaunchSpeed * (verticalAxis > 0f ? verticalLaunchWithVerticalAxisUpModifier : 1f) * (verticalAxis < 0f ? verticalLaunchWithVerticalAxisDownModifier : 1f));
        Vector2 resultVector = new Vector2(horizontalResult, verticalResult);
        resultVector.x += (playerVelocity.x * horizontalInertiaModifier);
        resultVector.y += (playerVelocity.y * verticalInertiaModifier);

        return resultVector;
    }
}
