using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDamage : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] int mageTemperDamage = 2;
    [SerializeField] int dragonTemperDamage = -1;
    [SerializeField] float baseVerticalKnockback = 2f;
    [SerializeField] float baseHorizontalKnockback = 5f;
    [SerializeField] float crouchingModifier = 0.5f;
    [SerializeField] float baseHitstunTime = 1f;
    [SerializeField] float knockbackMagnitudeEpsilon = 0.001f;
    [SerializeField] float postDamageInvulnerabilityTime = 3f;
    [SerializeField] Vector3 nullSourceVector;
    [SerializeField, Range(0f, 1f)] float invulnerabilityAlpha = 0.75f;
    [SerializeField] PhysicsMaterial2D normalMaterial;
    [SerializeField] PhysicsMaterial2D damagedMaterial;
    [SerializeField] PhysicsMaterial2D fullFrictionMaterial;

    private Vector3 damageSource;
    private float hitstunTimer = 0f;
    private bool isDamageInvulnerabilityFlickering = false;

    public bool isDamageInvulnerabilityActive { get; private set; }
    public bool isPlayerDamaged { get { return hitstunTimer > 0f; } }
    public int damageTaken { get; private set; }

    void Awake()
    {
        player = this.gameObject.GetComponent<PlayerCtrl>();
        damageSource = nullSourceVector;
    }

    void Update()
    {
        if (!PauseHandler.isPaused)
        {
            Color spriteColor = player.charSprite.color;
            if (isDamageInvulnerabilityActive && isDamageInvulnerabilityFlickering)
            {
                spriteColor.a = invulnerabilityAlpha;
            }
            else
            {
                spriteColor.a = 1f;
            }
            player.charSprite.color = spriteColor;
            isDamageInvulnerabilityFlickering = !isDamageInvulnerabilityFlickering;
        }
    }

    public void TakeDamage(Vector3 source)
    {
        if (hitstunTimer > 0f || !CanTakeDamage()) { return; }
        damageTaken++;
        damageSource = source;
        StartCoroutine(HitstunTimerCR(baseHitstunTime * (player.movement.isCrouching ? crouchingModifier : 1f)));
        player.temper.ChangeTemperBy((int)((player.form.currentMode == CharacterMode.MAGE ? mageTemperDamage : dragonTemperDamage) * (player.movement.isCrouching ? crouchingModifier : 1f)));
        MedalFragment.DropFragments();
        player.buffers.ResetSpeedBuffer();
        player.jumping.ResetSuperJumpTimers();
        player.sfxCtrl.PlaySound("damage_player");
    }

    public void DoKnockback()
    {
        if (damageSource.z != 0f) { return; }

        Vector3 playerPos = this.transform.position;
        Vector3 damageSrcPos = damageSource;
        float xDiff = (playerPos.x - damageSrcPos.x);
        float horizontalDirection = (xDiff > 0f ? 1f : -1f);

        player.rb2d.gravityScale = player.jumping.fallingGravity;
        Vector2 newVelocity = new Vector2(horizontalDirection * baseHorizontalKnockback, baseVerticalKnockback);
        newVelocity *= (player.movement.isCrouching ? crouchingModifier : 1f);
        player.rb2d.velocity = newVelocity;

        damageSource = nullSourceVector;

        player.effects.DroppedFragmentsEffect();
    }

    public void DoIFrames()
    {
        if (isDamageInvulnerabilityActive) { return; }
        StartCoroutine(PostDamageIFramesCR(postDamageInvulnerabilityTime));
    }

    private bool CanTakeDamage()
    {
        string currentState = player.stateMachine.CurrentState.name;
        return (!isDamageInvulnerabilityActive && !player.attacks.isBlastJumpActive && player.attacks.currentAttackState != AttackState.ACTIVE && currentState != "Dodging" && currentState != "FormChanging" && currentState != "Damaged");
    }

    private IEnumerator HitstunTimerCR(float time)
    {
        if (hitstunTimer > 0f) { yield break; }

        hitstunTimer = time;
        
        while (player.stateMachine.CurrentState != player.stateMachine.damagedState)
        {
            player.rb2d.sharedMaterial = damagedMaterial;
            yield return null;
        }

        while (!player.collisions.IsGrounded || player.rb2d.velocity.magnitude >= knockbackMagnitudeEpsilon)
        {
            player.rb2d.sharedMaterial = damagedMaterial;
            yield return null;
        }
        
        while (hitstunTimer > 0f)
        {
            player.rb2d.sharedMaterial = fullFrictionMaterial;
            player.rb2d.velocity = Vector2.zero;
            hitstunTimer -= Time.deltaTime;
            if (hitstunTimer < 0f)
            {
                hitstunTimer = 0f;
            }
            yield return null;
        }

        player.rb2d.sharedMaterial = normalMaterial;
    }

    private IEnumerator PostDamageIFramesCR(float time)
    {
        if (isDamageInvulnerabilityActive) { yield break; }

        isDamageInvulnerabilityFlickering = false;

        isDamageInvulnerabilityActive = true;
        yield return new WaitForSeconds(time);
        isDamageInvulnerabilityActive = false;
    }
}
