using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public enum DamageType { STOMP, MAGIC_BLAST, BLAST_JUMP, FIRE_TACKLE, FIRE_MISSILE, PARRY, REFLECTED_PROJECTILE }

public class EnemyBehavior : MonoBehaviour
{
    [SerializeField] DamageType[] immuneTo;

    [SerializeField] UnityEvent onRoomActive;
    [SerializeField] UnityEvent onDefeat;

    [HideInInspector] public Rigidbody2D rb2d;
    [HideInInspector] public SpriteRenderer enemySprite;

    [HideInInspector] public EnemyMovement movement;
    [HideInInspector] public EnemyCollisionDetection collisionDetection;
    [HideInInspector] public EnemyPlayerDetection playerDetection;
    [HideInInspector] public EnemyProjectile projectile;
    [HideInInspector] public EnemyAnimation animationCtrl;

    [SerializeField] float defeatedDeactivationCameraDistance = 25f;
    [SerializeField] float verticalLaunchOnDefeat = 2f;
    [SerializeField] string sortingLayerOnDefeat = "Effects";

    public bool isVisible { get; private set; }
    public bool isStunned { get; private set; }
    public bool isDefeated { get; private set; }

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        enemySprite = this.gameObject.GetComponent<SpriteRenderer>();

        movement = this.gameObject.GetComponent<EnemyMovement>();
        collisionDetection = this.gameObject.GetComponent<EnemyCollisionDetection>();
        playerDetection = this.gameObject.GetComponent<EnemyPlayerDetection>();
        projectile = this.gameObject.GetComponent<EnemyProjectile>();
        animationCtrl = this.gameObject.GetComponent<EnemyAnimation>();
    }

    void Start()
    {
        
    }

    void Update()
    {
        CheckDefeatedCameraDistance();
    }

    void OnBecameVisible()
    {
        isVisible = true;
    }

    void OnBecameInvisible()
    {
        isVisible = false;
    }

    public void ActivateEnemy()
    {
        if (!isDefeated)
        {
            onRoomActive.Invoke();
        }
    }

    public void PlayDamageSound()
    {
        SoundFactory.SpawnSound("damage_enemy", this.transform.position, 0.65f);
    }

    public void SpawnDragoonShades()
    {
        GameObject tempObj = EffectFactory.SpawnEffect("DragoonShadesDefeated", projectile.enemyProjectileSpawnPoint.position);
        DragoonShadesFall tempShades = tempObj.GetComponent<DragoonShadesFall>();
        tempShades.Setup(rb2d.velocity, enemySprite.flipX);
    }

    public bool DefeatEnemy(DamageType dmgType)
    {
        if (IsImmune(dmgType)) { return false; }

        if (!isDefeated)
        {
            isDefeated = true;
            rb2d.velocity = (Vector2.up * verticalLaunchOnDefeat);
            enemySprite.sortingLayerName = sortingLayerOnDefeat;
            onDefeat.Invoke();
            return true;
        }
        return false;
    }

    public void StunEnemy()
    {

    }

    private bool IsImmune(DamageType dmgType)
    {
        foreach (DamageType d in immuneTo)
        {
            if (dmgType == d) { return true; }
        }
        return false;
    }

    private void CheckDefeatedCameraDistance()
    {
        if (isDefeated)
        {
            Vector3 cameraPosition = Camera.main.transform.position;
            cameraPosition.z = 0f;

            Vector3 thisPosition = this.transform.position;

            if (Vector3.Distance(cameraPosition, thisPosition) >= defeatedDeactivationCameraDistance)
            {
                this.gameObject.SetActive(false);
            }
        }
    }
}
