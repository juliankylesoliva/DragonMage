using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MedalFragment : MonoBehaviour
{
    public static int totalFragments { get { return (mageFragments + dragonFragments); } }
    public static int mageFragments { get; private set; }
    public static int dragonFragments { get; private set; }

    private const int MAX_FRAGMENTS_DROPPED = 10;
    private const int BASE_FRAGMENT_DROP_SPLIT = 5;
    private const int MIN_FRAGMENT_DROP_SPLIT_MODIFER = -5;
    private const int MAX_FRAGMENT_DROP_SPLIT_MODIFER = 5;

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.tag == "Player")
        {
            PlayerCtrl playerRef = other.gameObject.GetComponent<PlayerCtrl>();
            if (playerRef != null)
            {
                if (playerRef.form.currentMode == CharacterMode.MAGE)
                {
                    mageFragments++;
                }
                else
                {
                    dragonFragments++;
                }
            }

            this.gameObject.SetActive(false);
        }
    }

    public static void ResetFragments()
    {
        mageFragments = 0;
        dragonFragments = 0;
    }

    public static void DropFragments()
    {
        if (totalFragments > 0)
        {
            if (totalFragments <= MAX_FRAGMENTS_DROPPED)
            {
                mageFragments = 0;
                dragonFragments = 0;
            }
            else
            {
                if (mageFragments == 0)
                {
                    dragonFragments -= MAX_FRAGMENTS_DROPPED;
                }
                else if (dragonFragments == 0)
                {
                    mageFragments -= MAX_FRAGMENTS_DROPPED;
                }
                else
                {
                    int mageFragmentsToDrop = BASE_FRAGMENT_DROP_SPLIT;
                    int dragonFragmentsToDrop = BASE_FRAGMENT_DROP_SPLIT;

                    int fragmentDifference = (mageFragments - dragonFragments);
                    if (fragmentDifference != 0)
                    {
                        fragmentDifference = Mathf.Min(Mathf.Max(fragmentDifference, MIN_FRAGMENT_DROP_SPLIT_MODIFER), MAX_FRAGMENT_DROP_SPLIT_MODIFER);
                        mageFragmentsToDrop += fragmentDifference;
                        dragonFragmentsToDrop -= fragmentDifference;
                    }

                    mageFragments -= mageFragmentsToDrop;
                    dragonFragments -= dragonFragmentsToDrop;
                }
            }
        }
    }
}
