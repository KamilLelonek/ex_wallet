defmodule ExWallet.Extended.PathlistTest do
  use ExUnit.Case, async: true

  alias ExWallet.Extended.Pathlist

  describe "to_list" do
    test "should create normal private list" do
      assert {:private, [1, 2, 3, 4]} = Pathlist.to_list("m/1/2/3/4")
    end

    test "should create normal public list" do
      assert {:public, [5, 6, 7, 8]} = Pathlist.to_list("M/5/6/7/8")
    end

    test "should create normal list" do
      assert [9, 10, 11, 12] = Pathlist.to_list("9/10/11/12")
    end

    test "should create hardened private list" do
      assert {:private, [2_147_483_661, 2_147_483_662, 2_147_483_663, 2_147_483_664]} =
               Pathlist.to_list("m/13'/14'/15'/16'")
    end

    test "should create hardened public list" do
      assert {:public, [2_147_483_665, 2_147_483_666, 2_147_483_667, 2_147_483_668]} =
               Pathlist.to_list("M/17'/18'/19'/20'")
    end

    test "should create hardened list" do
      assert [2_147_483_669, 2_147_483_670, 2_147_483_671, 2_147_483_672] =
               Pathlist.to_list("21'/22'/23'/24'")
    end

    test "should create mixed private list" do
      assert {:private, [25, 26, 2_147_483_675, 28]} = Pathlist.to_list("m/25/26/27'/28")
    end

    test "should create public list" do
      assert {:public, [2_147_483_677, 30, 31, 32]} = Pathlist.to_list("M/29'/30/31/32")
    end

    test "should create mixed list" do
      assert [33, 2_147_483_682, 35, 2_147_483_684] = Pathlist.to_list("33/34'/35/36'")
    end
  end
end
