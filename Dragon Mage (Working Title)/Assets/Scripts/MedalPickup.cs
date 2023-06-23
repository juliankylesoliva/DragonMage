using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MedalPickup : MonoBehaviour
{
    Animator animator;

    [SerializeField] float nonNeutralRatio = 2f;

    private bool isNotBlank = false;

    void Awake()
    {
        animator = this.gameObject.GetComponent<Animator>();
    }

    void Update()
    {
        if (MedalFragment.totalFragments >= Level.FragmentsNeededForMedal)
        {
            isNotBlank = true;
            if (MedalFragment.dragonFragments == 0 || (MedalFragment.mageFragments / MedalFragment.dragonFragments) >= nonNeutralRatio)
            {
                animator.Play("MagicSpin");
            }
            else if (MedalFragment.mageFragments == 0 || (MedalFragment.dragonFragments / MedalFragment.mageFragments) >= nonNeutralRatio)
            {
                animator.Play("DragonSpin");
            }
            else
            {
                animator.Play("NeutralSpin");
            }
        }
        else
        {
            isNotBlank = false;
            animator.Play("BlankSpin");
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (isNotBlank && other.gameObject.tag == "Player")
        {
            SoundFactory.SpawnSound("object_medal_pickup", this.transform.position);
            this.gameObject.SetActive(false);
        }
    }
}
