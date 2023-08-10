using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDamage : MonoBehaviour
{
    PlayerCtrl player;

    [SerializeField] int mageTemperDamage = 2;
    [SerializeField] int dragonTemperDamage = -1;
    [SerializeField] int baseFragmentDropSplit = 5;
    [SerializeField] int maxFragmentDropFactor = 2;
    [SerializeField] float baseVerticalKnockback = 2f;
    [SerializeField] float baseHorizontalKnockback = 5f;
    [SerializeField] float crouchingModifier = 0.5f;
    [SerializeField] float baseHitstunTime = 1f;
    [SerializeField] float parryWindowTime = 0.1f;
    [SerializeField] float parryPoseTime = 0.25f;
    [SerializeField] float parryKnockbackMultiplier = 2f;
    [SerializeField] DamageType parryDamageType = DamageType.PARRY;
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

    private float parryTimer = 0f;
    private bool prevIsCrouching = false;

    public bool isDamageInvulnerabilityActive { get; private set; }
    public bool isPlayerDamaged { get { return hitstunTimer > 0f; } }
    public bool isBlocking { get; private set; }
    public bool isParrying { get { return parryTimer > 0f; } }
    public bool isParryPosing { get; private set; }
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
            DoIFrameSpriteAlpha();
            DoParryCheck();
        }
    }

    public void TakeDamage(Vector3 source, EnemyBehavior enemySrc = null, EnemyProjectileBehavior projectileSrc = null)
    {
        if (isParrying)
        {
            if (enemySrc != null)
            {
                if (enemySrc.DefeatEnemy(parryDamageType))
                {
                    enemySrc.rb2d.velocity += ((Vector2)(source - this.transform.position).normalized * parryKnockbackMultiplier);
                }
            }

            if (projectileSrc != null)
            {
                projectileSrc.ReflectProjectile();
            }

            player.temper.NeutralizeTemperBy(player.temper.NumSegments * (player.form.currentMode == CharacterMode.MAGE ? -1 : 1));
            player.sfxCtrl.PlaySound("attack_parry");
            ResetParryTimer();
            StartCoroutine(ParryPoseCR());
            return;
        }

        if (hitstunTimer > 0f || !CanTakeDamage()) { return; }
        isBlocking = player.movement.isCrouching;

        damageTaken++;
        damageSource = source;
        StartCoroutine(HitstunTimerCR(baseHitstunTime * (isBlocking ? crouchingModifier : 1f)));
        if (isBlocking)
        {
            player.temper.NeutralizeTemperBy((int)((player.form.currentMode == CharacterMode.MAGE ? mageTemperDamage : dragonTemperDamage) * crouchingModifier));
        }
        else
        {
            player.temper.ChangeTemperBy(player.form.currentMode == CharacterMode.MAGE ? mageTemperDamage : dragonTemperDamage);
        }
        
        CalculateDroppedFragments(isBlocking ? crouchingModifier : 1f);
        player.buffers.ResetSpeedBuffer();
        player.jumping.ResetSuperJumpTimers();
        player.sfxCtrl.PlaySound(isBlocking ? "damage_player_guarding" : "damage_player");
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
        newVelocity *= (isBlocking ? crouchingModifier : 1f);
        player.rb2d.velocity = newVelocity;

        damageSource = nullSourceVector;
    }

    public void DoIFrames()
    {
        if (isDamageInvulnerabilityActive) { return; }
        StartCoroutine(PostDamageIFramesCR(postDamageInvulnerabilityTime));
    }

    private bool CanTakeDamage()
    {
        string currentState = player.stateMachine.CurrentState.name;
        return (!isParrying && !isDamageInvulnerabilityActive && !player.attacks.isBlastJumpActive && player.attacks.currentAttackState != AttackState.ACTIVE && currentState != "Dodging" && currentState != "FormChanging" && currentState != "Damaged");
    }

    private void CalculateDroppedFragments(float modifier)
    {
        int droppedMageFragments = 0;
        int droppedDragonFragments = 0;

        int fragmentDropSplit = (int)Mathf.Ceil(modifier * baseFragmentDropSplit);
        int maxFragmentDrop = (fragmentDropSplit * maxFragmentDropFactor);

        if (MedalFragment.totalFragments > 0)
        {
            if (MedalFragment.totalFragments <= maxFragmentDrop)
            {
                droppedMageFragments = MedalFragment.mageFragments;
                droppedDragonFragments = MedalFragment.dragonFragments;
            }
            else
            {
                if (MedalFragment.mageFragments == 0)
                {
                    droppedDragonFragments = maxFragmentDrop;
                }
                else if (MedalFragment.dragonFragments == 0)
                {
                    droppedMageFragments = maxFragmentDrop;
                }
                else
                {
                    int mageFragmentsToDrop = fragmentDropSplit;
                    int dragonFragmentsToDrop = fragmentDropSplit;

                    int fragmentDifference = (MedalFragment.mageFragments - MedalFragment.dragonFragments);
                    if (fragmentDifference != 0)
                    {
                        fragmentDifference = Mathf.Min(Mathf.Max(fragmentDifference, -fragmentDropSplit), fragmentDropSplit);
                        mageFragmentsToDrop += fragmentDifference;
                        dragonFragmentsToDrop -= fragmentDifference;

                        if (mageFragmentsToDrop > MedalFragment.mageFragments)
                        {
                            mageFragmentsToDrop = MedalFragment.mageFragments;
                            dragonFragmentsToDrop = (maxFragmentDrop - mageFragmentsToDrop);
                        }
                        else if (dragonFragmentsToDrop > MedalFragment.dragonFragments)
                        {
                            dragonFragmentsToDrop = MedalFragment.dragonFragments;
                            mageFragmentsToDrop = (maxFragmentDrop - dragonFragmentsToDrop);
                        }
                        else { /* Nothing */ }
                    }
                    droppedMageFragments = mageFragmentsToDrop;
                    droppedDragonFragments = dragonFragmentsToDrop;
                }
            }
        }

        MedalFragment.DropFragments(droppedMageFragments, droppedDragonFragments);
        player.effects.DroppedFragmentsEffect(droppedMageFragments, droppedDragonFragments);
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

    private void DoIFrameSpriteAlpha()
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

    private void DoParryCheck()
    {
        if (parryTimer <= 0f)
        {
            if (!isDamageInvulnerabilityActive && !player.crouchButtonHeld && !player.movement.isCrouching && prevIsCrouching) { parryTimer = parryWindowTime; }
        }
        else
        {
            if (parryTimer > 0f)
            {
                parryTimer -= Time.deltaTime;
                if (player.movement.isCrouching || parryTimer < 0f)
                {
                    parryTimer = 0f;
                }
            }
        }
        prevIsCrouching = player.movement.isCrouching;
    }

    private void ResetParryTimer()
    {
        parryTimer = 0f;
    }

    private IEnumerator ParryPoseCR()
    {
        if (isParryPosing) { yield break; }
        isParryPosing = true;

        Vector2 prevVelocity = player.rb2d.velocity;

        player.rb2d.gravityScale = 0f;
        player.rb2d.velocity = Vector2.zero;

        yield return new WaitForSeconds(parryPoseTime);

        player.rb2d.gravityScale = (prevVelocity.y > 0f ? player.jumping.risingGravity : player.jumping.fallingGravity);
        player.rb2d.velocity = prevVelocity;

        isParryPosing = false;
    }
}
