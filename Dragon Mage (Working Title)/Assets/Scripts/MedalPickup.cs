using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum MedalStatus { NOT_PICKED_UP, MAGIC_MEDAL_GET, DRAGON_MEDAL_GET, BALANCE_MEDAL_GET };

public class MedalPickup : MonoBehaviour
{
    Animator animator;
    Rigidbody2D rb2d;

    [SerializeField] float nonNeutralRatio = 2f;
    [SerializeField] float pickupVerticalVelocity = 5f;
    [SerializeField] float pickupGravityScale = 2f;
    [SerializeField] float pickupAnimationSpeed = 2f;
    [SerializeField] float pickupExpireTime = 0.5f;

    private MedalStatus currentMedalStatus = MedalStatus.NOT_PICKED_UP;
    private bool isNotBlank = false;
    private bool isPickedUp = false;
    private bool isBeingDestroyed = false;

    public static MedalStatus medalPickedUpStatus { get; private set; }

    void Awake()
    {
        animator = this.gameObject.GetComponent<Animator>();
        rb2d = this.gameObject.GetComponent<Rigidbody2D>();
        medalPickedUpStatus = MedalStatus.NOT_PICKED_UP;
    }

    void Update()
    {
        if (MedalFragment.totalFragments >= Level.FragmentsNeededForMedal)
        {
            isNotBlank = true;
            if (MedalFragment.dragonFragments == 0 || (MedalFragment.mageFragments / MedalFragment.dragonFragments) >= nonNeutralRatio)
            {
                currentMedalStatus = MedalStatus.MAGIC_MEDAL_GET;
                animator.Play("MagicSpin");
            }
            else if (MedalFragment.mageFragments == 0 || (MedalFragment.dragonFragments / MedalFragment.mageFragments) >= nonNeutralRatio)
            {
                currentMedalStatus = MedalStatus.DRAGON_MEDAL_GET;
                animator.Play("DragonSpin");
            }
            else
            {
                currentMedalStatus = MedalStatus.BALANCE_MEDAL_GET;
                animator.Play("NeutralSpin");
            }
        }
        else
        {
            isNotBlank = false;
            currentMedalStatus = MedalStatus.NOT_PICKED_UP;
            animator.Play("BlankSpin");
        }
    }

    private IEnumerator DestroySelf()
    {
        if (!isPickedUp || isBeingDestroyed) { yield break; }
        isBeingDestroyed = true;
        yield return new WaitForSeconds(pickupExpireTime);
        GameObject.Destroy(this.gameObject);
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (!isBeingDestroyed && isNotBlank && !isPickedUp && currentMedalStatus != MedalStatus.NOT_PICKED_UP && other.gameObject.tag == "Player")
        {
            isPickedUp = true;
            SoundFactory.SpawnSound("object_medal_pickup", this.transform.position);
            medalPickedUpStatus = currentMedalStatus;
            rb2d.constraints = RigidbodyConstraints2D.None;
            rb2d.gravityScale = pickupGravityScale;
            rb2d.velocity = (Vector2.up * pickupVerticalVelocity);
            animator.speed = pickupAnimationSpeed;
            StartCoroutine(DestroySelf());
        }
    }
}
