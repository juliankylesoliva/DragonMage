using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagicBlast : MonoBehaviour
{
    /* COMPONENTS */
    Rigidbody2D rb2d;
    AudioPlayer sfxCtrl;

    /* DRAG AND DROP */
    [SerializeField] GameObject blastHitboxPrefab;

    /* EDITOR VARIABLES */
    [SerializeField] SpriteRenderer spriteRenderer;
    [SerializeField] Color defaultColor;
    [SerializeField] Color pulseColor;
    [SerializeField] float despawnDistance = 20f;
    [SerializeField] float fuseTime = 3f;

    [SerializeField] float verticalLaunchSpeed = 1f;
    [SerializeField] float verticalLaunchWithVerticalAxisUpModifier = 5f;
    [SerializeField] float verticalLaunchWithVerticalAxisDownModifier = -0.5f;
    [SerializeField] float verticalInertiaModifier = 0.25f;

    [SerializeField] float horizontalLaunchSpeed = 2f;
    [SerializeField] float horizontalLaunchWithVerticalAxisModifier = 0.25f;
    [SerializeField] float horizontalInertiaModifier = 0.5f;
    
    [SerializeField] float rotationSpeed = 10f;
    [SerializeField] float blastDuration = 0.1f;
    [SerializeField] float blastStrength = 3f;
    [SerializeField] float blastRadius = 1.5f;

    /* SCRIPT VARIABLES */
    private GameObject playerRef;
    private PlayerTemper temper;
    private float fuseTimeLeft = 0f;
    private float currentLerpValue = 0f;

    void Awake()
    {
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        sfxCtrl = this.gameObject.GetComponent<AudioPlayer>();
    }

    void Start()
    {
        fuseTimeLeft = fuseTime;
    }

    void Update()
    {
        spriteRenderer.color = Color.Lerp(defaultColor, pulseColor, Mathf.PingPong(currentLerpValue, 1f));
        fuseTimeLeft -= Time.deltaTime;
        currentLerpValue += ((fuseTime / fuseTimeLeft) * Time.deltaTime);

        if (fuseTimeLeft <= 0f)
        {
            Detonate();
        }
        else if (playerRef != null && Vector3.Distance(this.transform.position, playerRef.transform.position) > despawnDistance)
        {
            GameObject.Destroy(this.gameObject);
        }
        else { /* Nothing */ }
    }

    public void Detonate()
    {
        GameObject tempEffect = EffectFactory.SpawnEffect("MagicExplosion", this.transform.position);
        tempEffect.transform.localScale = new Vector3(blastRadius / 0.5f, blastRadius / 0.5f, 1f);
        GameObject tempObj = Instantiate(blastHitboxPrefab, this.transform.position, Quaternion.identity);
        BlastHitbox tempBlast = tempObj.GetComponent<BlastHitbox>();
        tempBlast.Setup(temper, blastDuration, blastStrength, blastRadius);
        GameObject.Destroy(this.gameObject);
    }

    public void Setup(GameObject player, PlayerTemper temper, Vector2 playerVelocity, bool isGoingRight = true, float verticalAxis = 0f)
    {
        playerRef = player;
        this.temper = temper;
        float horizontalResult = ((isGoingRight ? horizontalLaunchSpeed : -horizontalLaunchSpeed) * (verticalAxis != 0f ? horizontalLaunchWithVerticalAxisModifier : 1f));
        float verticalResult = (verticalLaunchSpeed * (verticalAxis > 0f ? verticalLaunchWithVerticalAxisUpModifier : 1f) * (verticalAxis < 0f ? verticalLaunchWithVerticalAxisDownModifier : 1f));
        Vector2 resultVector = new Vector2(horizontalResult, verticalResult);
        resultVector.x += (playerVelocity.x * horizontalInertiaModifier);
        resultVector.y += (playerVelocity.y * verticalInertiaModifier);
        rb2d.velocity = resultVector;
        rb2d.AddTorque(rotationSpeed * (isGoingRight ? -1f : 1f) * (verticalAxis != 0f ? 0.5f : 1f));
    }

    void OnCollisionEnter2D(Collision2D other)
    {
        int otherLayer = other.transform.gameObject.layer;
        if (otherLayer == LayerMask.NameToLayer("Ground") || otherLayer == LayerMask.NameToLayer("Slopes") || otherLayer == LayerMask.NameToLayer("Blocks"))
        {
            SoundFactory.SpawnSound("attack_magli_bounce", other.transform.position, 0.25f);
        }
    }
}
